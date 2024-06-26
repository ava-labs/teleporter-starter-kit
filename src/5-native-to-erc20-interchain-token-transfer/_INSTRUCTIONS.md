# Transfer a Subnet's Native Token to the C-Chain

The following code example will show you how to send a Subnet's native token to the C-Chain using Teleporter and Foundry. This demo is conducted on a local network run by the CLI, but can be applied to Fuji Testnet and Avalanche Mainnet directly.

**All Avalanche Interchain Token Transfer contracts and interfaces implemented in this example implementation are maintained in the [avalanche-interchain-token-transfer](https://github.com/ava-labs/avalanche-interchain-token-transfer/tree/main/contracts/src) repository.**

If you prefer full end-to-end testing written in Golang for bridging ERC20s, native tokens, or any combination of the two, you can view the test workflows directly in the [avalanche-interchain-token-transfer](https://github.com/ava-labs/avalanche-interchain-token-transfer/tree/main/tests/flows) repository.

Deep dives on each template interface can be found [here](https://github.com/ava-labs/avalanche-interchain-token-transfer/blob/main/contracts/README.md).

_Disclaimer: The avalanche-interchain-token-transfer contracts used in this tutorial are under active development and are not yet intended for production deployments. Use at your own risk._

## Local Network Environment

For convenience the private key `56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027` of the default airdrop address is stored in the environment variable `$PK` in `.devcontainer/devcontainer.json`. Furthermore, the RPC url for the C-Chain `local-c` and any Subnet created with the name `mysubnet` on a local network is set in the `foundry.toml` file.

### Useful Commands

This tutorial uses the Avalanche-CLI. Some useful commands you can utilize to get information about your local network and Subnet during testing are:

- `avalanche primary describe`: prints details of the primary network configuration, including `blockchainID` to the console
- `avalanche subnet describe <subnetName>`: prints details of the subnet configuration, including `blockchainID` to the console
- `avalanche key list --local --subnet <subnetName>`: prints information for all stored signing keys, including native token balances

## Subnet Configuration

To get started, create a Subnet configuration named "mysubnet":

```zsh
avalanche subnet create mysubnet
```

Your Subnet should have Teleporter enabled, the CLI should run an AWM Relayer, and upon Subnet deployment, 1,000,000 tokens should be airdropped to the default ewoq address:

```zsh
? Choose your VM:
✔ Subnet-EVM
? What version of Subnet-EVM would you like?:
✔ Use latest release version
? Would you like to enable Teleporter on your VM?:
✔ Yes
? Would you like to run AMW Relayer when deploying your VM?:
✔ Yes
Installing subnet-evm-v0.6.4...
subnet-evm-v0.6.4 installation successful
creating genesis for subnet mysubnet
Enter your subnet's ChainId. It can be any positive integer.
ChainId: 012345
Select a symbol for your subnet's native token
Token symbol: NATV
? How would you like to set fees:
✔ Low disk use    / Low Throughput    1.5 mil gas/s (C-Chain's setting)
? How would you like to distribute funds:
✔ Airdrop 1 million tokens to the default ewoq address (do not use in production)
prefunding address 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC with balance 1000000000000000000000000
? Advanced: Would you like to add a custom precompile to modify the EVM?:
✔ No
✓ Successfully created subnet configuration
```

Finally, deploy your Subnet:

```zsh
avalanche subnet deploy mysubnet
```

```zsh
? Choose a network for the operation:
✔ Local Network
Deploying [mysubnet] to Local Network
```

The CLI will output addresses and information that will be important for the rest of the tutorial:

```zsh
Deploying Blockchain. Wait until network acknowledges...

Teleporter Messenger successfully deployed to c-chain (0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
Teleporter Registry successfully deployed to c-chain (0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25)

Teleporter Messenger successfully deployed to mysubnet (0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
Teleporter Registry successfully deployed to mysubnet (0x004e6Bb21bc27E5F367EB278Be0ef39cDD1A77F6)

<lots of node information
...>

Browser Extension connection details (any node URL from above works):
RPC URL:           http://127.0.0.1:9650/ext/bc/G8ckkPsWkKdbXjDDU77wzL8sS4w67N2afG6MXKbDmvrQG5R7B/rpc
Codespace RPC URL: https://expert-space-fishstick-wqg5x974rpqc9wqp-9650.app.github.dev/ext/bc/G8ckkPsWkKdbXjDDU77wzL8sS4w67N2afG6MXKbDmvrQG5R7B/rpc
Funded address:    0x6c86eE2D6e789c44dE1a15669aEb87cE9A8a80E9 with 600
Funded address:    0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC with 1000000 (10^18) - private key: 56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027
Network name:      mysubnet
Chain ID:          797979
Currency Symbol:   NATV
```

From this output, take note of the following parameters, **which will vary with each Subnet deployment**:

| Parameter                      | Value                                      |
| :----------------------------- | :----------------------------------------- |
| Funded Address (with 1000000)  | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC |
| Teleporter Registry (c-chain)  | 0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25 |
| Teleporter Registry (mysubnet) | 0x004e6Bb21bc27E5F367EB278Be0ef39cDD1A77F6 |

Set these parameters as environment variables so that we can manage them easily and also use them in the commands later.

```bash
export FUNDED_ADDRESS=<Funded Address (with 100 tokens)>
export TELEPORTER_REGISTRY_C_CHAIN=<Teleporter Registry on C-chain>
export TELEPORTER_REGISTRY_SUBNET=<Teleporter Registry on Subnet>
```

## Parameter Management

As you deploy the teleporter contracts, keeping track of their addresses will make testing and troubleshooting much easier. The parameters you should keep track of include:

| Parameter                     | Network | Description                                                                                                                                         |
| :---------------------------- | :------ | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| Funded Address (with 1000000) | Both    | The public address you use to deploy contracts, and send tokens through the Avalanche Interchain Token Transfer. Used as the `teleporterManager` constructor parameter in this example. |
| Teleporter Registry           | C-Chain | Address of the TeleporterRegistry contract on C-Chain deployed by the CLI                                                                           |
| Teleporter Registry           | Subnet  | Address of the TeleporterRegistry contract on Subnet deployed by the CLI                                                                            |
| Wrapped Native Token          | Subnet  | Address of the wrapped token contract for your Subnet's native token to be deployed on the Subnet                                                   |
| Native Token Home           | Subnet  | Address of the Transferer's Home contract to be deployed on the Subnet                                                                                |
| ERC20 Remote            | C-Chain | Address of the Transferer's remote contract to be deployed on the C-Chain                                                                          |
| Subnet Blockchain ID          | Subnet  | Hexadecimal representation of the Subnet's Blockchain ID. Returned by `avalanche subnet describe <subnetName>`.                                     |
| C-Chain Blockchain ID         | C-Chain | Hexadecimal representation of the C-Chain's Blockchain ID on the selected network. Returned by `avalanche primary describe`.                        |

## Deploy Avalanche Interchain Token Transfer Contracts

### Wrapped Native Token

On your Subnet, deploy a wrapped token contract for your native token. When we configured the Subnet earlier, we named the token `NATV`. This is reflected in line 19 of our [example wrapped token contract](./ExampleWNATV.sol).

```
forge create --rpc-url mysubnet --private-key $PK src/5-native-to-erc20-interchain-token-transfer/ExampleWNATV.sol:WNATV
```

Export the "Deployed to" address as an environment variables.

```bash
export WRAPPED_ERC20_HOME_SUBNET=<"Deployed to" address>
```

```zsh
[⠊] Compiling...
[⠃] Compiling 7 files with Solc 0.8.18
[⠊] Solc 0.8.18 finished in 778.12ms
Compiler run successful!
Deployer: 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC
Deployed to: 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922
Transaction hash: 0x054e7b46b221c30f400b81df0fa2601668ae832054cf8e8b873f4ba615fa4115
```

### Native Token Home

To Transfer the token out of your Subnet, you'll need to first deploy a _home_ contract on your Subnet that implements the `INativeTokenTransferer` interface, and inherits the properties of the `TeleporterTokenHome` contract standard.

Using the [`forge create`](https://book.getfoundry.sh/reference/forge/forge-create) command, we will deploy the [NativeTokenHome.sol](./NativeTokenHome.sol) contract, passing in the following constructor arguments:

```zsh
forge create --rpc-url mysubnet --private-key $PK lib/avalanche-interchain-token-transfer/contracts/src/TokenHome/NativeTokenHome.sol:NativeTokenHome --constructor-args $TELEPORTER_REGISTRY_SUBNET $FUNDED_ADDRESS $WRAPPED_ERC20_HOME_SUBNET
```

- Teleporter Registry (for our Subnet)
- Teleporter Manager (our funded address)
- Wrapped Token Address (deployed in the last step)

For example, this foundry command could be entered into your terminal as:

```zsh
forge create --rpc-url mysubnet --private-key $PK src/5-native-interchain-token-transfer/NativeTokenHome.sol:NativeTokenHome --constructor-args 0xAd00Ce990172Cfed987B0cECd3eF58221471a0a3 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922
```

Note the address the home contract was "Deployed to".

```zsh
export ERC20_HOME_TRANSFERER_SUBNET=<"Deployed to" address>
```

### ERC20 Remote

To ensure the wrapped token is transfered into the destination chain (in this case, C-Chain) you'll need to deploy a _remote_ contract that implements the `IERC20TokenTransferer` interface, as well as inheriting the properties of `TeleporterTokenRemote`. In order for the transfered tokens to have all the normal functionality of a locally deployed ERC20 token, this remote contract must also inherit the properties of a standard `ERC20` contract.

First, get the `Source Blockchain ID` in hexidecimal format, which in this example is the BlockchainID of your Subnet, run:

```zsh
avalanche subnet describe mysubnet
```

```bash
export SUBNET_BLOCKCHAIN_ID_HEX=0x4d569bf60a38e3ab3e92afd016fe37f7060d7d63c44e3378f42775bf82a7642d
```

`Source Blockchain ID` is in the field: `Local Network BlockchainID (HEX)`.

Using the [`forge create`](https://book.getfoundry.sh/reference/forge/forge-create) command, we will deploy the [ERC20Remote.sol](./NativeTokenHome.sol) contract, passing in the following constructor arguments:

```zsh
forge create --rpc-url local-c --private-key $PK lib/avalanche-interchain-token-transfer/contracts/src/TokenRemote/ERC20TokenRemote.sol:ERC20TokenRemote --constructor-args "(${TELEPORTER_REGISTRY_C_CHAIN}, ${FUNDED_ADDRESS}, ${SUBNET_BLOCKCHAIN_ID_HEX}, ${ERC20_HOME_TRANSFERER_SUBNET})" "Wrapped NATV" "WNATV" 18
```

- Teleporter Registry Address **(for C-Chain)**
- Teleporter Manager (our funded address)
- Source Blockchain ID (hexidecimal representation of our Subnet's Blockchain ID)
- Token Home Address (address of NativeTokenHome.sol deployed on Subnet in the last step)
- Token Name (input in the constructor of the [wrapped token contract](./ExampleWNATV.sol))
- Token Symbol (input in the constructor of the [wrapped token contract](./ExampleWNATV.sol))
- Token Decimals (uint8 integer representing number of decimal places for the ERC20 token being created. Most ERC20 tokens follow the Ethereum standard, which defines 18 decimal places.)

For example, this contract deployment could be entered into your terminal as:

```zsh
forge create --rpc-url local-c --private-key $PK \
lib/avalanche-interchain-token-transfer/contracts/src/TokenRemote/ERC20TokenRemote.sol:ERC20TokenRemote \
--constructor-args 0xAd00Ce990172Cfed987B0cECd3eF58221471a0a3 \
0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC \
0xbcb8143686b1f0c765a1404bb94ad13134cafa5cf56f181a3a990ba21b1151b9 \
0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25 \
"Wrapped NATV" \
"WNATV" \
18
```

Note the address the remote contract was "Deployed to".

export ERC20_TOKEN_REMOTE_C_CHAIN=<"Deployed to" address>

## Register Remote Token with Home Transferer

After deploying the Transferer contracts, you'll need to register the Remote token by sending a dummy message using the `registerWithHome` method. This message includes details which inform the home Transferer about your destination blockchain and settings, eg. `initialReserveImbalance`.

```bash
cast send --rpc-url local-c --private-key $PK $ERC20_TOKEN_REMOTE_C_CHAIN "registerWithHome((address, uint256))" "(0x0000000000000000000000000000000000000000, 0)"
```

## Transfer the Token Cross-chain

First, get the `Destination Blockchain ID` in hexidecimal format, which in this example is the BlockchainID of your local C-Chain, run:

```zsh
avalanche primary describe
```

`Destination Blockchain ID` is in the field: `BlockchainID (HEX)`.

```bash
export C_CHAIN_BLOCKCHAIN_ID_HEX=0x55e1fcfdde01f9f6d4c16fa2ed89ce65a8669120a86f321eef121891cab61241
```

Now that all the Avalanche Interchain Token Transfer contracts have been deployed, send a native token from your Subnet to C-Chain with the [`cast send`](https://book.getfoundry.sh/reference/cast/cast-send) foundry command.

```zsh
cast send --rpc-url mysubnet --private-key $PK <TokenHomeAddress> \
"<functionToCall((parameterTypes))>" \
"(<functionParameter0>,<functionParameter1>,...)" \
--value <amountOfTokensToSend>
```

In line 60 of [`NativeTokenHome`](./NativeTokenHome.sol) is the send function we will call to send the tokens:

```sol
function send(SendTokensInput calldata input) external payable {
        _send(input, msg.value, false);
    }
```

The function parameters are defined by the `SendTokensInput` struct defined in line 26 of [`ITokenTransferer`](lib/avalanche-interchain-token-transfer/contracts/src/interfaces/ITokenTransferer.sol).

```sol
struct SendTokensInput {
    bytes32 destinationBlockchainID;
    address destinationBridgeAddress;
    address recipient;
    address feeTokenAddress;
    uint256 primaryFee;
    uint256 secondaryFee;
    uint256 requiredGasLimit;
}
```

- destinationBlockchainID: C-Chain Blockchain ID
- destinationBridgeAddress: ERC20 Remote address
- recipient: any Ethereum Address you want to send funds to
- feeTokenAddress: Wrapped Native Token address
- primaryFee: amount of tokens to pay for Teleporter fee on the source chain, can be 0 for this example
- secondaryFee: amount of tokens to pay for Teleporter fee if a multi-hop is needed, can be 0 for this example
- requiredGasLimit: gas limit requirement for an Interchain Token Transfer, can be 1000000 for this example

For example, this token transfer could be entered into your terminal as:

  function sendAndCall(SendAndCallInput calldata input) external payable {
        _sendAndCall({
            sourceBlockchainID: blockchainID,
            originBridgeAddress: address(this),
            originSenderAddress:_msgSender(),
            input: input,
            amount: msg.value,
            isMultiHop: false
        });
    }

struct SendTokensInput {
    bytes32 destinationBlockchainID;
    address destinationBridgeAddress;
    address recipient;
    address primaryFeeTokenAddress;
    uint256 primaryFee;
    uint256 secondaryFee;
    uint256 requiredGasLimit;
    address multiHopFallback;
}

```bash
cast send --rpc-url mysubnet --private-key $PK $ERC20_HOME_TRANSFERER_SUBNET "send((bytes32, address, address, address, uint256, uint256, uint256, address))" "(${C_CHAIN_BLOCKCHAIN_ID_HEX}, ${ERC20_TOKEN_REMOTE_C_CHAIN}, ${FUNDED_ADDRESS}, 0x0000000000000000000000000000000000000000, 0, 0, 250000, 0x0000000000000000000000000000000000000000)"  --value 1
```

If your parameters were entered correctly, this command will sign and publish a transaction, resulting in a large JSON response of transaction information in the terminal.

To confirm the token was transfered from Subnet to C-Chain, we will check the recipient's balance of wrapped tokens on the C-Chain with the [`cast call`](https://book.getfoundry.sh/reference/cast/cast-call?highlight=cast%20call#cast-call) foundry command:

```zsh
cast call --rpc-url local-c $ERC20_TOKEN_REMOTE_C_CHAIN "balanceOf(address)(uint)" $FUNDED_ADDRESS
```

If the command returns a balance greater than 0, congratulations, you've now successfully deployed an Avalanche Interchain Token Transferer and successfully sent tokens cross-chain!
