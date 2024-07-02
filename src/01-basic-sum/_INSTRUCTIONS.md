
# Instructions - Sum Send & Receive

The following code example will show you how to send a number on C-chain, and add up the number received on the destination chain. We will then verify the sum of the messages using teleporter and foundry. It includes instructions for the [local network](#local-network) and [fuji testnet](#fuji-testnet).

## Local Network

For convenience the private key `56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027` of the default airdrop address is stored in the environment variable `$PK`. Furthermore, the RPC-url for the C-Chain of your local network is set in the `foundry.toml` file.

### Setting the Blockchain ID in the Contracts

Make sure to replace the blockchainID in the sender contract `src/01-basic-sum/senderOnCChain.sol` with the ID of your Subnet's blockchain.

> :no_entry_sign: blockchainID of Subnet ≠ chainID of Subnet

You can find the blockchainID of your Subnet with this command:

```bash
avalanche subnet describe mysubnet
```

Take the HEX blockchain ID and replace it sender contract:

```solidity
teleporterMessenger.sendCrossChainMessage(
    TeleporterMessageInput({
        // Replace with blockchainID of your Subnet (see instructions in Readme)
        destinationBlockchainID: 0x3861e061737eaeb8d00f0514d210ad1062bfacdb4bd22d1d1f5ef876ae3a8921,
        destinationAddress: destinationAddress,
        
        // ...
    })
);
```

### Deploying the Contracts

After adapting the contracts you can deploy them with `forge create`:

```bash
forge create --rpc-url local-c --private-key $PK src/01-basic-sum/senderOnCChain.sol:SenderOnCChain

```

```bash
forge create --rpc-url mysubnet --private-key $PK src/01-basic-sum/receiverOnSubnet.sol:ReceiverOnSubnet
```

### Sending a Message

You can find `<sender_contract_address>` in the output of the first and the `<receiver_contract_address>` of the second `forge create` command in the line saying `Deployed to:`.

```bash
cast send --rpc-url local-c --private-key $PK <sender_contract_address> "sum(address,uint256)" <receiver_contract_address> 4
```

### Verifying Message Receipt

```bash
cast call --rpc-url mysubnet <receiver_contract_address> "sum()(uint256)"
```
