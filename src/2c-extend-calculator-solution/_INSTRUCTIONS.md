
# Deploy Sender on C-chain
forge create --rpc-url local-c --private-key $PK src/2-invoking-functions/2c-extend-calculator-solution/ExtCalculatorSenderOnCChain.sol:CalculatorSenderOnCChain


# Deploy Receiver on Subnet
forge create --rpc-url mysubnet --private-key $PK src/2-invoking-functions/2c-extend-calculator-solution/ExtCalculatorReceiverOnSubnet.sol:CalculatorReceiverOnSubnet

# Try sendTripleSumMessage
cast send --rpc-url local-c --private-key $PK 0x5DB9A7629912EBF95876228C24A848de0bfB43A9 "sendTripleSumMessage(address,uint256,uint256,uint256)"   0x52C84043CD9c865236f11d9Fc9F56aa003c1f922 4 3 2

# Verify result_num variable
cast call --rpc-url mysubnet 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922 "result_num()(uint256)"