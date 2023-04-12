# Solidity API

## WalletCoordinator

The wallet coordinator contract aims to facilitate the coordination
of the off-chain wallet members during complex multi-chain wallet
operations like deposit sweeping, redemptions, or moving funds.
Such processes involve various moving parts and many steps that each
individual wallet member must do. Given the distributed nature of
the off-chain wallet software, full off-chain implementation is
challenging and prone to errors, especially byzantine faults.
This contract provides a single and trusted on-chain coordination
point thus taking the riskiest part out of the off-chain software.
The off-chain wallet members can focus on the core tasks and do not
bother about electing a trusted coordinator or aligning internal
states using complex consensus algorithms.

### WalletAction

```solidity
enum WalletAction {
  Idle,
  DepositSweep,
  Redemption,
  MovingFunds,
  MovedFundsSweep
}
```

### WalletLock

```solidity
struct WalletLock {
  uint32 expiresAt;
  enum WalletCoordinator.WalletAction cause;
}
```

### WalletMemberContext

```solidity
struct WalletMemberContext {
  uint32[] walletMembersIDs;
  uint256 walletMemberIndex;
}
```

### DepositSweepProposal

```solidity
struct DepositSweepProposal {
  bytes20 walletPubKeyHash;
  struct WalletCoordinator.DepositKey[] depositsKeys;
  uint256 sweepTxFee;
}
```

### DepositKey

```solidity
struct DepositKey {
  bytes32 fundingTxHash;
  uint32 fundingOutputIndex;
}
```

### DepositExtraInfo

```solidity
struct DepositExtraInfo {
  struct BitcoinTx.Info fundingTx;
  bytes8 blindingFactor;
  bytes20 walletPubKeyHash;
  bytes20 refundPubKeyHash;
  bytes4 refundLocktime;
}
```

### isProposalSubmitter

```solidity
mapping(address => bool) isProposalSubmitter
```

Mapping that holds addresses allowed to submit proposals.

### walletLock

```solidity
mapping(bytes20 => struct WalletCoordinator.WalletLock) walletLock
```

Mapping that holds wallet time locks. The key is a 20-byte
wallet public key hash.

### bridge

```solidity
contract Bridge bridge
```

Handle to the Bridge contract.

### walletRegistry

```solidity
contract IWalletRegistry walletRegistry
```

Handle to the WalletRegistry contract.

### depositSweepProposalValidity

```solidity
uint32 depositSweepProposalValidity
```

Determines the deposit sweep proposal validity time. In other
words, this is the worst-case time for a deposit sweep during
which the wallet is busy and cannot take another actions. This
is also the duration of the time lock applied to the wallet
once a new deposit sweep proposal is submitted.

For example, if a deposit sweep proposal was submitted at
2 pm and depositSweepProposalValidity is 4 hours, the next
proposal (of any type) can be submitted after 6 pm.

### depositMinAge

```solidity
uint32 depositMinAge
```

The minimum time that must elapse since the deposit reveal
before a deposit becomes eligible for a deposit sweep.

For example, if a deposit was revealed at 9 am and depositMinAge
is 2 hours, the deposit is eligible for sweep after 11 am.

Forcing deposit minimum age ensures block finality for Ethereum.
In the happy path case, i.e. where the deposit is revealed immediately
after being broadcast on the Bitcoin network, the minimum age
check also ensures block finality for Bitcoin.

### depositRefundSafetyMargin

```solidity
uint32 depositRefundSafetyMargin
```

Each deposit can be technically swept until it reaches its
refund timestamp after which it can be taken back by the depositor.
However, allowing the wallet to sweep deposits that are close
to their refund timestamp may cause a race between the wallet
and the depositor. In result, the wallet may sign an invalid
sweep transaction that aims to sweep an already refunded deposit.
Such tx signature may be used to create an undefeatable fraud
challenge against the wallet. In order to mitigate that problem,
this parameter determines a safety margin that puts the latest
moment a deposit can be swept far before the point after which
the deposit becomes refundable.

For example, if a deposit becomes refundable after 8 pm and
depositRefundSafetyMargin is 6 hours, the deposit is valid for
for a sweep only before 2 pm.

### depositSweepMaxSize

```solidity
uint16 depositSweepMaxSize
```

The maximum count of deposits that can be swept within a
single sweep.

### depositSweepProposalSubmissionGasOffset

```solidity
uint32 depositSweepProposalSubmissionGasOffset
```

Gas that is meant to balance the deposit sweep proposal
submission overall cost. Can be updated by the owner based on
the current market conditions.

### ProposalSubmitterAdded

```solidity
event ProposalSubmitterAdded(address proposalSubmitter)
```

### ProposalSubmitterRemoved

```solidity
event ProposalSubmitterRemoved(address proposalSubmitter)
```

### WalletManuallyUnlocked

```solidity
event WalletManuallyUnlocked(bytes20 walletPubKeyHash)
```

### DepositSweepProposalValidityUpdated

```solidity
event DepositSweepProposalValidityUpdated(uint32 depositSweepProposalValidity)
```

### DepositMinAgeUpdated

```solidity
event DepositMinAgeUpdated(uint32 depositMinAge)
```

### DepositRefundSafetyMarginUpdated

```solidity
event DepositRefundSafetyMarginUpdated(uint32 depositRefundSafetyMargin)
```

### DepositSweepMaxSizeUpdated

```solidity
event DepositSweepMaxSizeUpdated(uint16 depositSweepMaxSize)
```

### DepositSweepProposalSubmissionGasOffsetUpdated

```solidity
event DepositSweepProposalSubmissionGasOffsetUpdated(uint32 depositSweepProposalSubmissionGasOffset)
```

### DepositSweepProposalSubmitted

```solidity
event DepositSweepProposalSubmitted(struct WalletCoordinator.DepositSweepProposal proposal, address proposalSubmitter)
```

### onlyProposalSubmitterOrWalletMember

```solidity
modifier onlyProposalSubmitterOrWalletMember(bytes20 walletPubKeyHash, struct WalletCoordinator.WalletMemberContext walletMemberContext)
```

### onlyAfterWalletLock

```solidity
modifier onlyAfterWalletLock(bytes20 walletPubKeyHash)
```

### onlyReimbursableAdmin

```solidity
modifier onlyReimbursableAdmin()
```

### initialize

```solidity
function initialize(contract Bridge _bridge) external
```

### addProposalSubmitter

```solidity
function addProposalSubmitter(address proposalSubmitter) external
```

Adds the given address to the proposal submitters set.

Requirements:
- The caller must be the owner,
- The `proposalSubmitter` must not be an existing proposal submitter.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| proposalSubmitter | address | Address of the new proposal submitter. |

### removeProposalSubmitter

```solidity
function removeProposalSubmitter(address proposalSubmitter) external
```

Removes the given address from the proposal submitters set.

Requirements:
- The caller must be the owner,
- The `proposalSubmitter` must be an existing proposal submitter.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| proposalSubmitter | address | Address of the existing proposal submitter. |

### unlockWallet

```solidity
function unlockWallet(bytes20 walletPubKeyHash) external
```

Allows to unlock the given wallet before their time lock expires.
This function should be used in exceptional cases where
something went wrong and there is a need to unlock the wallet
without waiting.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| walletPubKeyHash | bytes20 | 20-byte public key hash of the wallet |

### updateDepositSweepProposalValidity

```solidity
function updateDepositSweepProposalValidity(uint32 _depositSweepProposalValidity) external
```

Updates the value of the depositSweepProposalValidity parameter.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _depositSweepProposalValidity | uint32 | New value. |

### updateDepositMinAge

```solidity
function updateDepositMinAge(uint32 _depositMinAge) external
```

Updates the value of the depositMinAge parameter.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _depositMinAge | uint32 | New value. |

### updateDepositRefundSafetyMargin

```solidity
function updateDepositRefundSafetyMargin(uint32 _depositRefundSafetyMargin) external
```

Updates the value of the depositRefundSafetyMargin parameter.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _depositRefundSafetyMargin | uint32 | New value. |

### updateDepositSweepMaxSize

```solidity
function updateDepositSweepMaxSize(uint16 _depositSweepMaxSize) external
```

Updates the value of the depositSweepMaxSize parameter.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _depositSweepMaxSize | uint16 | New value. |

### updateDepositSweepProposalSubmissionGasOffset

```solidity
function updateDepositSweepProposalSubmissionGasOffset(uint32 _depositSweepProposalSubmissionGasOffset) external
```

Updates the value of the depositSweepProposalSubmissionGasOffset
parameter.

Requirements:
- The caller must be the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _depositSweepProposalSubmissionGasOffset | uint32 | New value. |

### submitDepositSweepProposal

```solidity
function submitDepositSweepProposal(struct WalletCoordinator.DepositSweepProposal proposal, struct WalletCoordinator.WalletMemberContext walletMemberContext) public
```

Submits a deposit sweep proposal. Locks the target wallet
for a specific time, equal to the proposal validity period.
This function does not store the proposal in the state but
just emits an event that serves as a guiding light for wallet
off-chain members. Wallet members are supposed to validate
the proposal on their own, before taking any action.

Requirements:
- The caller is either a proposal submitter or a member of the
target wallet,
- The wallet is not time-locked.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| proposal | struct WalletCoordinator.DepositSweepProposal | The deposit sweep proposal |
| walletMemberContext | struct WalletCoordinator.WalletMemberContext | Optional parameter holding some data allowing to confirm the wallet membership of the caller. This parameter is relevant only when the caller is not a registered proposal submitter but claims to be a member of the target wallet. |

### submitDepositSweepProposalWithReimbursement

```solidity
function submitDepositSweepProposalWithReimbursement(struct WalletCoordinator.DepositSweepProposal proposal, struct WalletCoordinator.WalletMemberContext walletMemberContext) external
```

Wraps `submitDepositSweepProposal` call and reimburses the
caller's transaction cost.

See `submitDepositSweepProposal` function documentation.

### validateDepositSweepProposal

```solidity
function validateDepositSweepProposal(struct WalletCoordinator.DepositSweepProposal proposal, struct WalletCoordinator.DepositExtraInfo[] depositsExtraInfo) external view returns (bool)
```

View function encapsulating the main rules of a valid deposit
sweep proposal. This function is meant to facilitate the off-chain
validation of the incoming proposals. Thanks to it, most
of the work can be done using a single readonly contract call.
Worth noting, the validation done here is not exhaustive as some
conditions may not be verifiable within the on-chain function or
checking them may be easier on the off-chain side. For example,
this function does not check the SPV proofs and confirmations of
the deposit funding transactions as this would require an
integration with the difficulty relay that greatly increases
complexity. Instead of that, each off-chain wallet member is
supposed to do that check on their own.

Requirements:
- The target wallet must be in the Live state,
- The number of deposits included in the sweep must be in
the range [1, `depositSweepMaxSize`],
- The length of `depositsExtraInfo` array must be equal to the
length of `proposal.depositsKeys`, i.e. each deposit must
have exactly one set of corresponding extra data,
- The proposed sweep tx fee must be grater than zero,
- The proposed maximum per-deposit sweep tx fee must be lesser than
or equal the maximum fee allowed by the Bridge (`Bridge.depositTxMaxFee`),
- Each deposit must be revealed to the Bridge,
- Each deposit must be old enough, i.e. at least `depositMinAge`
elapsed since their reveal time,
- Each deposit must not be swept yet,
- Each deposit must have valid extra data (see `validateDepositExtraInfo`),
- Each deposit must have the refund safety margin preserved,
- Each deposit must be controlled by the same wallet,
- Each deposit must target the same vault.

The following off-chain validation must be performed as a bare minimum:
- Inputs used for the sweep transaction have enough Bitcoin confirmations,
- Deposits revealed to the Bridge have enough Ethereum confirmations.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| proposal | struct WalletCoordinator.DepositSweepProposal | The sweeping proposal to validate. |
| depositsExtraInfo | struct WalletCoordinator.DepositExtraInfo[] | Deposits extra data required to perform the validation. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the proposal is valid. Reverts otherwise. |

### validateSweepTxFee

```solidity
function validateSweepTxFee(uint256 sweepTxFee, uint256 depositsCount) internal view
```

Validates the sweep tx fee by checking if the part of the fee
incurred by each deposit does not exceed the maximum value
allowed by the Bridge. This function is heavily based on
`DepositSweep.depositSweepTxFeeDistribution` function.

Requirements:
- The sweep tx fee must be grater than zero,
- The maximum per-deposit sweep tx fee must be lesser than or equal
the maximum fee allowed by the Bridge (`Bridge.depositTxMaxFee`).

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| sweepTxFee | uint256 | The sweep transaction fee. |
| depositsCount | uint256 | Count of the deposits swept by the sweep transaction. |

### validateDepositExtraInfo

```solidity
function validateDepositExtraInfo(struct WalletCoordinator.DepositKey depositKey, address depositor, struct WalletCoordinator.DepositExtraInfo depositExtraInfo) internal view
```

Validates the extra data for the given deposit. This function
is heavily based on `Deposit.revealDeposit` function.

Requirements:
- The transaction hash computed using `depositExtraInfo.fundingTx`
must match the `depositKey.fundingTxHash`. This requirement
ensures the funding transaction data provided in the extra
data container actually represent the funding transaction of
the given deposit.
- The P2(W)SH script inferred from `depositExtraInfo` is actually
used to lock funds by the `depositKey.fundingOutputIndex` output
of the `depositExtraInfo.fundingTx` transaction. This requirement
ensures the reveal data provided in the extra data container
actually matches the given deposit.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| depositKey | struct WalletCoordinator.DepositKey | Key of the given deposit. |
| depositor | address | Depositor that revealed the deposit. |
| depositExtraInfo | struct WalletCoordinator.DepositExtraInfo | Extra data being subject of the validation. |

