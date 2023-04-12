# Solidity API

## OutboundTx

Aggregates functions common to the redemption transaction proof
validation and to the moving funds transaction proof validation.

### processWalletOutboundTxInput

```solidity
function processWalletOutboundTxInput(struct BridgeState.Storage self, bytes walletOutboundTxInputVector, struct BitcoinTx.UTXO mainUtxo) internal
```

Checks whether an outbound Bitcoin transaction performed from
the given wallet has an input vector that contains a single
input referring to the wallet's main UTXO. Marks that main UTXO
as correctly spent if the validation succeeds. Reverts otherwise.
There are two outbound transactions from a wallet possible: a
redemption transaction or a moving funds to another wallet
transaction.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| self | struct BridgeState.Storage |  |
| walletOutboundTxInputVector | bytes | Bitcoin outbound transaction's input vector. This function assumes vector's structure is valid so it must be validated using e.g. `BTCUtils.validateVin` function before it is passed here. |
| mainUtxo | struct BitcoinTx.UTXO | Data of the wallet's main UTXO, as currently known on the Ethereum chain. |

### parseWalletOutboundTxInput

```solidity
function parseWalletOutboundTxInput(bytes walletOutboundTxInputVector) internal pure returns (bytes32 outpointTxHash, uint32 outpointIndex)
```

Parses the input vector of an outbound Bitcoin transaction
performed from the given wallet. It extracts the single input
then the transaction hash and output index from its outpoint.
There are two outbound transactions from a wallet possible: a
redemption transaction or a moving funds to another wallet
transaction.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| walletOutboundTxInputVector | bytes | Bitcoin outbound transaction input vector. This function assumes vector's structure is valid so it must be validated using e.g. `BTCUtils.validateVin` function before it is passed here. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| outpointTxHash | bytes32 | 32-byte hash of the Bitcoin transaction which is pointed in the input's outpoint. |
| outpointIndex | uint32 | 4-byte index of the Bitcoin transaction output which is pointed in the input's outpoint. |

