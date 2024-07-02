// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/upgrades/TeleporterRegistry.sol";
import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";
import "./MyERC20Token.sol";
import "./BridgeActions.sol";

contract TokenMinterReceiverOnDestination is ITeleporterReceiver {
    TeleporterRegistry public immutable teleporterRegistry =
        TeleporterRegistry(0x55e1dcC96FaBD72a104eAa7ae333F97554BA103B);
    address public tokenAddress;

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only a Teleporter Messenger registered in the registry can deliver a message.
        // Function throws an error if msg.sender is not registered.
        teleporterRegistry.getVersionFromAddress(msg.sender);

        // Decoding the Action type:
        (BridgeAction actionType, bytes memory paramsData) = abi.decode(message, (BridgeAction, bytes));

        // Route to the appropriate function.
        if (actionType == BridgeAction.createToken) {
            (string memory name, string memory symbol) = abi.decode(paramsData, (string, string));
            tokenAddress = address(new myToken(name, symbol));
        } else if (actionType == BridgeAction.mintToken) {
            (address recipient, uint256 amount) = abi.decode(paramsData, (address, uint256));
            myToken(tokenAddress).mint(recipient, amount);
        } else {
            revert("Receiver: invalid action");
        }
    }
}
