// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

interface IPixpelSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event ChainConfigUpdated(uint256 newChainId, address newSkaleWeth);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event FeeToUpdated(address indexed newFeeTo, address indexed updater);

    function feeTo() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address _feeTo) external;
    function setSkaleChainConfig(uint256 newChainId, address newSkaleWeth) external;

    // role management
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
     function renounceRole(bytes32 role) external;
   

    // role identifiers
    function PAIR_CREATOR_ROLE() external pure returns (bytes32);
    function FEE_MANAGER_ROLE() external pure returns (bytes32);
    function CHAIN_MANAGER_ROLE() external pure returns (bytes32);

    // view helper
    function roles(address account, bytes32 role) external view returns (bool);
}
