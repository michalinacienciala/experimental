# Solidity API

## IWormholeTokenBridge

Wormhole Token Bridge interface. Contains only selected functions
used by L2WormholeGateway.

### completeTransferWithPayload

```solidity
function completeTransferWithPayload(bytes encodedVm) external returns (bytes)
```

### parseTransferWithPayload

```solidity
function parseTransferWithPayload(bytes encoded) external pure returns (struct IWormholeTokenBridge.TransferWithPayload transfer)
```

### transferTokens

```solidity
function transferTokens(address token, uint256 amount, uint16 recipientChain, bytes32 recipient, uint256 arbiterFee, uint32 nonce) external payable returns (uint64 sequence)
```

### transferTokensWithPayload

```solidity
function transferTokensWithPayload(address token, uint256 amount, uint16 recipientChain, bytes32 recipient, uint32 nonce, bytes payload) external payable returns (uint64 sequence)
```

### TransferWithPayload

```solidity
struct TransferWithPayload {
  uint8 payloadID;
  uint256 amount;
  bytes32 tokenAddress;
  uint16 tokenChain;
  bytes32 to;
  uint16 toChain;
  bytes32 fromAddress;
  bytes payload;
}
```

