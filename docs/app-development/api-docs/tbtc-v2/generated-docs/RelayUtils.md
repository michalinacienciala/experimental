# Solidity API

## RelayUtils

### extractTimestampAt

```solidity
function extractTimestampAt(bytes headers, uint256 at) internal pure returns (uint32)
```

Extract the timestamp of the header at the given position.

Assumes that the specified position contains a valid header.
Performs no validation whatsoever.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| headers | bytes | Byte array containing the header of interest. |
| at | uint256 | The start of the header in the array. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint32 | The timestamp of the header. |

