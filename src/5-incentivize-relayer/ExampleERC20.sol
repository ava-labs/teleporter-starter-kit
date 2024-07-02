// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity 0.8.18;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
import {ERC20} from "@openzeppelin/contracts@4.8.1/token/ERC20/ERC20.sol";

contract ExampleERC20 {
    string private constant _TOKEN_NAME = "Fee Token";
    string private constant _TOKEN_SYMBOL = "FEE";

    constructor() ERC20(_TOKEN_NAME, _TOKEN_SYMBOL) {
        _mint(msg.sender, 1e28);
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
