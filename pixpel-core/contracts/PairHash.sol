pragma solidity ^0.5.16;

import "./PixpelSwapPair.sol";

contract HashChecker {
    function getInitCodeHash() external pure returns (bytes32) {
        return keccak256(abi.encodePacked(type(PixpelSwapPair).creationCode));
    }
}
