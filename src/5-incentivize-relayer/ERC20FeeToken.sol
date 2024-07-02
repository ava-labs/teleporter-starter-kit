// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts@4.8.1/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts@4.8.1/access/Ownable.sol";

contract FeeToken is ERC20, Ownable {
    constructor() ERC20("FeeToken", "Fee") Ownable() {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
