// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import './interfaces/IPixpelSwapFactory.sol';
import './PixpelSwapPair.sol';

contract PixpelSwapFactory is IPixpelSwapFactory {
    address public feeTo;
    address public feeToSetter;
    //only for test
    // uint256 public chainIdOverride;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event ChainConfigUpdated(uint256 newChainId, address newSkaleWeth);

    //restricetd chain id for skale
    uint256 public SKALE_CHAIN_ID = 37084624;
    address public SKALE_WETH = 0x95ac999302Ff402b39A8B952a662863338585d3c;

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    //only for test
    // function setChainIdOverride(uint256 _id) external {
    //     chainIdOverride = _id;
    // }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'PixpelSwap: IDENTICAL_ADDRESSES');
        // Check chain ID
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        //only for test
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
        require(getPair[token0][token1] == address(0), 'PixpelSwap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(PixpelSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(pair != address(0), 'Create2 failed');

        IPixpelSwapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'PixpelSwap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'PixpelSwap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setSkaleChainConfig(uint256 newChainId, address newSkaleWeth) external {
        require(msg.sender == feeToSetter, 'PixpelSwap: FORBIDDEN');
        require(newSkaleWeth != address(0), 'PixpelSwap: ZERO_ADDRESS');
        SKALE_CHAIN_ID = newChainId;
        SKALE_WETH = newSkaleWeth;
        emit ChainConfigUpdated(newChainId, newSkaleWeth);
    }
}
