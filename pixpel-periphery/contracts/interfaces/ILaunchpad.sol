// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

interface ILaunchpad {
    function isTokenUsedInValidLaunchpad(address tokenAddress) external view returns (bool);
}
