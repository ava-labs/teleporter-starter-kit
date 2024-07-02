pragma solidity 0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";
import "./myNFT.sol";

contract NFTMinterReceiverOnDestination is ITeleporterReceiver {
    ITeleporterMessenger public immutable teleporterMessenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    address public CollectionAddresss;

    enum Action {
        createNFT,
        mintNFT
    }

    // Errors
    error Unauthorized();

    /**
     * @dev See {ITeleporterReceiver-receiveTeleporterMessage}.
     *
     * Receives a message from another chain.
     */
    function receiveTeleporterMessage(bytes32 originChainID, address originSenderAddress, bytes calldata message)
        external
    {
        // Only the Teleporter receiver can deliver a message.
        if (msg.sender != address(teleporterMessenger)) {
            revert Unauthorized();
        }

        // Decoding the Action type:
        (Action actionType, bytes memory paramsData) = abi.decode(message, (Action, bytes));

        // Route to the appropriate function.
        if (actionType == Action.createNFT) {
            (string memory name, string memory symbol) = abi.decode(paramsData, (string, string));
            CollectionAddresss = address(new myNFT(name, symbol, address(this)));
        } else if (actionType == Action.mintNFT) {
            (address recipient, uint256 tokenId) = abi.decode(paramsData, (address, uint256));
            myNFT(CollectionAddresss).safeMint(recipient, tokenId);
        } else {
            revert("Receiver: invalid action");
        }
    }
}
