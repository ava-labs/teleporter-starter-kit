#!/usr/bin/env bash
# Copyright (C) 2023, Ava Labs, Inc. All rights reserved.
# See the file LICENSE for licensing terms.

set -e # Stop on first error

# Variables provided by run_setup.sh:
#   user_private_key = $PK
user_address = 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC
#   c_chain_blockchain_id = 
mysubnet_blockchain_id = 0x135f18345685851cab136a663eefca628f4974427848ef8f8430b37fbe5c8d09
#   c_chain_blockchain_id_hex
#   subnet_a_blockchain_id_hex
teleporter_contract_address = 0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf
#   warp_messenger_precompile_addr

# Test covers:
# - Sending mint cross chain messages between the C-Chain and a subnet chain, by interacting with the Sender Contract
# - Sending mint cross chain messages between the C-Chain and a subnet chain, by interacting with the Sender Contract
# - Checking message delivery for message that was sent on destination chain.

# Deploy a test ERC20 to be used as Relayer incentives in the E2E test.
cd contracts
erc20_deploy_result=$(forge create --private-key $PK src/5-incentivize-relayer/ERC20FeeToken.sol:FeeToken --rpc-url local-c)
erc20_contract_address_c_chain=$(parseContractAddress "$erc20_deploy_result")
echo "Test ERC20 contract deployed to $erc20_contract_address_c_chain on the C-Chain"

# Mint Tokens to Funded Account (Skip this part since the constructor already mints some funds)
# Verify the Balance
balance_fee_token=cast call --rpc-url local-c --private-key $PK  $erc20_contract_address_c_chain "BalanceOf(address)(uint256)" $user_address)
echo "ERC20 FeeToken balance of $user_address on the C-Chain"

# Replace Blockchain ID in Sender (TODO: Requires modifying the contract to take blockchainID as parameter)
# Replace Fee Contract in Sender (TODO: Requires modifying to take fee contract as parameter)
# Deploy Sender
sender_deploy_result=$(forge create --private-key $PK src/5-incentivize-relayer/NFTMinterSenderWithFeesOnSource.sol:NFTMinterSenderWithFeesOnSource  --rpc-url local-c)
sender_contract_address_c_chain=$(parseContractAddress "$sender_deploy_result")
echo "Test Sender contract deployed to $sender_contract_address_c_chain on the C-Chain"

# Deploy Receiver
receiver_deploy_result=$(forge create --private-key $PK src/5-incentivize-relayer/NFTMinterReceiver.sol:NFTMinterReceiverOnDestination  --rpc-url mysubent)
receiver_contract_address_subnet=$(parseContractAddress "$receiver_deploy_result")
echo "Test Receiver contract deployed to $receiver_contract_address_subnet on the Subnet"

# Approve the Sender contract to use some ERC20 tokens from the user account we're using to incentivize the transactions
approve_amount=100000000000000000000000000000
cast send $erc20_contract_address_c_chain "approve(address,uint256)(bool)" $sender_contract_address_c_chain \
    $approve_amount \
    --private-key $PK --rpc-url local-c
result=$(cast call $erc20_contract_address_c_chain "allowance(address,address)(uint256)" $user_address $sender_contract_address_c_chain --rpc-url local-c)
result=$(echo $result | cut -d' ' -f1)
if [[ $result -ne $approve_amount ]]; then
    echo $result
    echo $approve_amount
    echo "Error approving Teleporter contract to spend ERC20 from user account."
    exit 1
fi

# Send NFT Creation Message
cast send --rpc-url local-c --private-key $PK <sender_contract_address> "sendMessage(address,string,string)" <receiver_contract_address> <name> <symbol>
# Confirm Creation

# Mint NFT



