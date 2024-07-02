// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "./CalculatorActions.sol";

contract CalculatorSenderOnCChain {
    ITeleporterMessenger public immutable teleporterMessenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    function sendAddMessage(address destinationAddress, uint256 num1, uint256 num2) external {
        teleporterMessenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Replace with chain id of your Subnet (see instructions in Readme)
                destinationBlockchainID: 0x3861e061737eaeb8d00f0514d210ad1062bfacdb4bd22d1d1f5ef876ae3a8921,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: encodeAddData(num1, num2)
            })
        );
    }

    function sendConcatenateMessage(address destinationAddress, string memory text1, string memory text2) external {
        teleporterMessenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Replace with chain id of your Subnet (see instructions in Readme)
                destinationBlockchainID: 0x3861e061737eaeb8d00f0514d210ad1062bfacdb4bd22d1d1f5ef876ae3a8921,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: encodeConcatenateData(text1, text2)
            })
        );
    }

    function sendTripleSumMessage(address destinationAddress, uint256 num1, uint256 num2, uint256 num3) external {
        teleporterMessenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Replace with chain id of your Subnet (see instructions in Readme)
                destinationBlockchainID: 0x3861e061737eaeb8d00f0514d210ad1062bfacdb4bd22d1d1f5ef876ae3a8921,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: encodeTripleSumData(num1, num2, num3)
            })
        );
    }

    //Encode helpers
    function encodeAddData(uint256 a, uint256 b) public pure returns (bytes memory) {
        bytes memory paramsData = abi.encode(a, b);
        return abi.encode(CalculatorAction.add, paramsData);
    }

    function encodeConcatenateData(string memory a, string memory b) public pure returns (bytes memory) {
        bytes memory paramsData = abi.encode(a, b);
        return abi.encode(CalculatorAction.concatenate, paramsData);
    }

    function encodeTripleSumData(uint256 a, uint256 b, uint256 c) public pure returns (bytes memory) {
        bytes memory paramsData = abi.encode(a, b, c);
        return abi.encode(CalculatorAction.tripleSum, paramsData);
    }
}
