// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/upgrades/TeleporterRegistry.sol";
import "@teleporter/ITeleporterMessenger.sol";
import "./BridgeActions.sol";

contract ERC20MinterSenderOnCChain {
    // The Teleporter registry contract manages different Teleporter contract versions.
    TeleporterRegistry public immutable teleporterRegistry =
        TeleporterRegistry(0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25);

    /**
     * @dev Sends a message to another chain.
     */
    function sendCreateTokenMessage(address destinationAddress, string memory name, string memory symbol) external {
        ITeleporterMessenger messenger = teleporterRegistry.getLatestTeleporter();

        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Replace with chain id of your Subnet (see instructions in Readme)
                destinationBlockchainID: 0x3ad215cfcefedc0e0e85aabf46c2a8ad09351235007955c877df81ae911d6511,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: encodeCreateTokenData(name, symbol)
            })
        );
    }

    function sendMintTokenMessage(address destinationAddress, address to, uint256 amount) external {
        ITeleporterMessenger messenger = teleporterRegistry.getLatestTeleporter();

        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x3ad215cfcefedc0e0e85aabf46c2a8ad09351235007955c877df81ae911d6511,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: encodeMintTokenData(to, amount)
            })
        );
    }

    //Encode helpers
    function encodeCreateTokenData(string memory name, string memory symbol) public pure returns (bytes memory) {
        bytes memory paramsData = abi.encode(name, symbol);
        return abi.encode(BridgeAction.createToken, paramsData);
    }

    function encodeMintTokenData(address to, uint256 amount) public pure returns (bytes memory) {
        bytes memory paramsData = abi.encode(to, amount);
        return abi.encode(BridgeAction.mintToken, paramsData);
    }
}
