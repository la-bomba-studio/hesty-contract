# Solidity API

## ReferralSystem

### ctrHestyControl

```solidity
contract IHestyAccessControl ctrHestyControl
```

### rewardToken

```solidity
address rewardToken
```

### tokenFactory

```solidity
contract ITokenFactory tokenFactory
```

### rewards

```solidity
mapping(address => mapping(uint256 => uint256)) rewards
```

### totalRewards

```solidity
mapping(address => uint256) totalRewards
```

### globalRewards

```solidity
mapping(address => uint256) globalRewards
```

### rewardsByProperty

```solidity
mapping(uint256 => uint256) rewardsByProperty
```

### numberOfRef

```solidity
mapping(address => uint256) numberOfRef
```

### referredBy

```solidity
mapping(address => address) referredBy
```

### approvedCtrs

```solidity
mapping(address => bool) approvedCtrs
```

### AddPropertyRefRewards

```solidity
event AddPropertyRefRewards(uint256 id, address onBehalfOf, uint256 amount)
```

### AddGlobalRewards

```solidity
event AddGlobalRewards(address onBehalfOf, uint256 amount)
```

### NewTokenFactory

```solidity
event NewTokenFactory(address newFactory)
```

### NewHestyAccessControl

```solidity
event NewHestyAccessControl(address newAccessControl)
```

### NewRewardToken

```solidity
event NewRewardToken(address newRewardToken)
```

### NewApprovedCtr

```solidity
event NewApprovedCtr(address newReferralRouter)
```

### RemovedApprovedCtr

```solidity
event RemovedApprovedCtr(address router)
```

### ClaimPropertyRewards

```solidity
event ClaimPropertyRewards(uint256 projectId, address user, uint256 rew)
```

### ClaimGlobalRewards

```solidity
event ClaimGlobalRewards(address user, uint256 rew)
```

### constructor

```solidity
constructor(address rewardToken_, address ctrHestyControl_, address tokenFactory_) public
```

_Referral System Constructor
        @param  rewardToken_ Token Reward (EURC)
        @param  ctrHestyControl_ Hesty Access Control Contract
        @param  tokenFactory_ Token Factory Contract_

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

_Checks that Hesty Contracts are not paused_

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

_Checks that `user` has kyc completed_

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

_Checks that `user` is not blacklisted_

### onlyAdmin

```solidity
modifier onlyAdmin()
```

_Checks that `msg.sender` is an Admin_

### addRewards

```solidity
function addRewards(address onBehalfOf, address user, uint256 projectId, uint256 amount) external
```

_Add Rewards Associated to a Property Project
        @dev    It emits a `AddPropertyRefRewards` event
        @param  onBehalfOf User who referred and the one that will receive the income
        @param  user The user who were referenced by onBehalfOf user
        @param  projectId The Property project
        @param  amount The amount of rewards_

### addGlobalRewards

```solidity
function addGlobalRewards(address onBehalfOf, uint256 amount) external
```

_Add Rewards Not Associated to a Property Project
        @dev    It emits a `AddGlobalRewards` event
        @param  onBehalfOf User who will receive rewards
        @param  amount The amount of rewards_

### claimPropertyRewards

```solidity
function claimPropertyRewards(address user, uint256 projectId) external
```

_Claim Property Rewards
        @dev    It emits a `ClaimPropertyRewards` event
        @param  user The user who earned referral revenue
        @param  projectId The Property Id_

### claimGlobalRewards

```solidity
function claimGlobalRewards(address user) external
```

_Claim Global Rewards
        @dev    It emits a `ClaimGlobalRewards` event
        @param  user The user who earned referral revenue_

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

_Return Number of user referrals and user referral revenues
        @param  user The user who referred others_

### addApprovedCtrs

```solidity
function addApprovedCtrs(address newReferralRouter) external
```

_Adds Contracts and Addresses that can add referral rewards
        @dev    It emits a `NewApprovedCtr` event
        @param  newReferralRouter Address that will add referral rewards_

### removeApprovedCtrs

```solidity
function removeApprovedCtrs(address oldReferralRouter) external
```

_Remove Approved Contract Routers
        @dev    It emits a `RemovedApprovedCtr` event
        @param  oldReferralRouter Address that added referral rewards_

### setRewardToken

```solidity
function setRewardToken(address newToken) external
```

_Set New Reward Token
        @dev    It emits a `NewRewardToken` event
        @param  newToken The Reward Token Address_

### setHestyAccessControlCtr

```solidity
function setHestyAccessControlCtr(address newControl) external
```

_Set New Hesty Accces Control Contract
        @dev    It emits a `NewHestyAccessControl` event
        @param  newControl The New Hesty Access Control_

### setNewTokenFactory

```solidity
function setNewTokenFactory(address newFactory) external
```

_Set New Hesty Factory Contract
        @dev    It emits a `NewTokenFactory` event
        @param  newFactory The New Hesty Factory_

