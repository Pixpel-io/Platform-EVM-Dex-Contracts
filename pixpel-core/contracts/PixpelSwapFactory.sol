// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import './interfaces/IPixpelSwapFactory.sol';
import './PixpelSwapPair.sol';

contract PixpelSwapFactory is IPixpelSwapFactory {
    address public feeTo;
    address public admin;

    // role identifiers
    bytes32 public constant PAIR_CREATOR_ROLE = keccak256('PAIR_CREATOR_ROLE');
    bytes32 public constant FEE_MANAGER_ROLE = keccak256('FEE_MANAGER_ROLE');
    bytes32 public constant CHAIN_MANAGER_ROLE = keccak256('CHAIN_MANAGER_ROLE');

    // role storage
    mapping(address => mapping(bytes32 => bool)) public roles;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event ChainConfigUpdated(uint256 newChainId, address newSkaleWeth);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event FeeToUpdated(address indexed newFeeTo, address indexed updater);

    // restricted chain id for skale
    uint256 public SKALE_CHAIN_ID = 37084624;
    address public SKALE_WETH = 0x95ac999302Ff402b39A8B952a662863338585d3c;

    // --- Testing fields ---
    // uint256 public chainIdOverride; // only for test

    modifier onlyAdmin() {
        require(msg.sender == admin, 'PixpelSwap: NOT_ADMIN');
        _;
    }

    modifier onlyRole(bytes32 role) {
        require(roles[msg.sender][role], 'PixpelSwap: ROLE_NOT_ASSIGNED');
        _;
    }

    constructor() public {
        admin = msg.sender;
        // grant deployer all roles initially
        roles[msg.sender][PAIR_CREATOR_ROLE] = true;
        roles[msg.sender][FEE_MANAGER_ROLE] = true;
        roles[msg.sender][CHAIN_MANAGER_ROLE] = true;
    }

    // --- Admin role management ---
    function grantRole(bytes32 role, address account) external onlyAdmin {
        roles[account][role] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public onlyAdmin {
        roles[account][role] = false;
        emit RoleRevoked(role, account, msg.sender);
    }

    function renounceRole(bytes32 role) public {
        require(roles[msg.sender][role], 'PixpelSwap: ROLE_NOT_ASSIGNED');
        roles[msg.sender][role] = false;
        emit RoleRevoked(role, msg.sender, msg.sender);
    }

    // --- View helpers ---
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    // --- Testing function ---
    // function setChainIdOverride(uint256 _id) external onlyAdmin {
    //     chainIdOverride = _id;
    // }

    // --- Core DEX logic ---
    function createPair(address tokenA, address tokenB) external onlyRole(PAIR_CREATOR_ROLE) returns (address pair) {
        require(tokenA != tokenB, 'PixpelSwap: IDENTICAL_ADDRESSES');

        // check chain ID
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        // for testing: allow overriding chain ID
        // if (chainIdOverride != 0) {
        //     chainId = chainIdOverride;
        // }

        if (chainId == SKALE_CHAIN_ID) {
            require(
                tokenA != SKALE_WETH && tokenB != SKALE_WETH,
                'PixpelSwapFactory: Native token pairs restricted on SKALE chain'
            );
        }

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PixpelSwap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'PixpelSwap: PAIR_EXISTS');

        bytes memory bytecode = type(PixpelSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(pair != address(0), 'PixpelSwap: CREATE2_FAILED');

        IPixpelSwapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);

        renounceRole(PAIR_CREATOR_ROLE);
    }

    function setFeeTo(address _feeTo) external onlyRole(FEE_MANAGER_ROLE) {
        feeTo = _feeTo;
        emit FeeToUpdated(_feeTo, msg.sender);
    }

    function setSkaleChainConfig(uint256 newChainId, address newSkaleWeth) external onlyRole(CHAIN_MANAGER_ROLE) {
        require(newSkaleWeth != address(0), 'PixpelSwap: ZERO_ADDRESS');
        SKALE_CHAIN_ID = newChainId;
        SKALE_WETH = newSkaleWeth;
        emit ChainConfigUpdated(newChainId, newSkaleWeth);
    }

    function INIT_CODE_HASH() external pure returns (bytes32) {
        return keccak256(type(PixpelSwapPair).creationCode);
    }
}
