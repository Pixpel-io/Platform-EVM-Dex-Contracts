// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

import '../PixpelSwapERC20.sol';

contract ERC20 is PixpelSwapERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
