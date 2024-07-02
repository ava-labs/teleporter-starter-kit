

1. Deploy the ERC20 Token to be used for paying the fees to the relayer
```bash
forge create --rpc-url local-c --private-key $PK src/5-incentivize-relayer/ERC20FeeToken.sol:FeeToken 

```


2. mint tokens to your funded account: 

```bash
cast send --rpc-url local-c --private-key $PK <fee_token_address> "mint(address,uint256)" <your_address> <Amount_to_mint>

cast send --rpc-url local-c --private-key $PK 0x5DB9A7629912EBF95876228C24A848de0bfB43A9 "mint(address,uint256)" 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC 10000000000000000000

```

2.a) Verify the balance of FEE tokens  *************
cast call --rpc-url local-c --private-key $PK <fee_token_address> "BalanceOf(address)(uint256)" <your_address>
cast call --rpc-url local-c --private-key $PK 0x5DB9A7629912EBF95876228C24A848de0bfB43A9 "balanceOf(address)(uint256)" 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC


3. Replace blockchain Id and Fee contract in Sender contract
BlockchainID: 0x135f18345685851cab136a663eefca628f4974427848ef8f8430b37fbe5c8d09 
Fee Contract: 0x5DB9A7629912EBF95876228C24A848de0bfB43A9

4. Deploy Sender on C-chain
```bash
forge create --rpc-url local-c --private-key $PK src/5-incentivize-relayer/NFTMinterSenderWithFeesOnSource.sol:NFTMinterSenderWithFeesOnSource 

0xa4DfF80B4a1D748BF28BC4A271eD834689Ea3407
```

5. Deploy Receiver on mysubnet
```bash
forge create --rpc-url mysubnet --private-key $PK src/5-incentivize-relayer/NFTMinterReceiver.sol:NFTMinterReceiverOnDestination
```

0x52C84043CD9c865236f11d9Fc9F56aa003c1f922

6. Send Message
```bash
cast send --rpc-url local-c --private-key $PK <sender_contract_address> "sendMessage(address,string,string)" <receiver_contract_address> <name> <symbol>

cast send --rpc-url local-c --private-key $PK 0xa4DfF80B4a1D748BF28BC4A271eD834689Ea3407 "sendCreateNFTMessage(address,string,string)" 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922 MyNFT MYN
```


