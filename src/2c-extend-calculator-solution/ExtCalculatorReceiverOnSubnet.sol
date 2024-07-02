// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";
import "./CalculatorActions.sol";

contract CalculatorReceiverOnSubnet is ITeleporterReceiver {
    ITeleporterMessenger public immutable teleporterMessenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    uint256 public result_num;
    string public result_string;

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        require(
            msg.sender == address(teleporterMessenger), "CalculatorReceiverOnSubnet: unauthorized TeleporterMessenger"
        );

        // Decoding the Action type:
        (CalculatorAction actionType, bytes memory paramsData) = abi.decode(message, (CalculatorAction, bytes));

        // Route to the appropriate function.
        if (actionType == CalculatorAction.add) {
            (uint256 a, uint256 b) = abi.decode(paramsData, (uint256, uint256));
            _calculatorAdd(a, b);
        } else if (actionType == CalculatorAction.concatenate) {
            (string memory text1, string memory text2) = abi.decode(paramsData, (string, string));
            _calculatorConcatenateStrings(text1, text2);
        } else if (actionType == CalculatorAction.tripleSum) {
            (uint256 a, uint256 b, uint256 c) = abi.decode(paramsData, (uint256, uint256, uint256));
            _calculatorTripleSum(a, b, c);
        } else {
            revert("ReceiverOnSubnet: invalid action");
        }
    }

    function _calculatorAdd(uint256 _num1, uint256 _num2) internal {
        result_num = _num1 + _num2;
    }

    function _calculatorConcatenateStrings(string memory str1, string memory str2) internal {
        bytes memory str1Bytes = bytes(str1);
        bytes memory str2Bytes = bytes(str2);

        bytes memory combined = new bytes(str1Bytes.length + str2Bytes.length + 1);

        for (uint256 i = 0; i < str1Bytes.length; i++) {
            combined[i] = str1Bytes[i];
        }
        combined[str1Bytes.length] = " ";
        for (uint256 i = 0; i < str2Bytes.length; i++) {
            combined[str1Bytes.length + i + 1] = str2Bytes[i];
        }

        result_string = string(combined);
    }

    function _calculatorTripleSum(uint256 _num1, uint256 _num2, uint256 _num3) internal {
        result_num = _num1 + _num2 + _num3;
    }
}
