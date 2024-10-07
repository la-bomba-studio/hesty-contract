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

Rewards earned by user indexed to each property

### globalRewards

```solidity
mapping(address => uint256) globalRewards
```

Total rewards earned by user indexed to properties

### rewardsByProperty

```solidity
mapping(uint256 => uint256) rewardsByProperty
```

Total rewards earned by user not indexed to properties

### numberOfRef

```solidity
mapping(address => uint256) numberOfRef
```

Total rewards earned by users filtered by property

### referredBy

```solidity
mapping(address => address) referredBy
```

Number of referrals a user has

### approvedCtrs

```solidity
mapping(address => bool) approvedCtrs
```

Who reffered the user

### AddPropertyRefRewards

```solidity
event AddPropertyRefRewards(uint256 id, address onBehalfOf, uint256 amount)
```

Approved addresses that can add property rewards

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

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

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
        @param  onBehalfOf User who referred and the one that will receive the income
        @param  user The user who were referenced by onBehalfOf user
        @param  projectId The Property project
        @param  amount The amount of rewards_

### addGlobalRewards

```solidity
function addGlobalRewards(address onBehalfOf, uint256 amount) external
```

_Add Rewards Not Associated to a Property Project
        @param  onBehalfOf User who will receive rewards
        @param  amount The amount of rewards_

### claimPropertyRewards

```solidity
function claimPropertyRewards(address user, uint256 projectId) external
```

Claim User Property Referral rewards

### claimGlobalRewards

```solidity
function claimGlobalRewards(address user) external
```

Claim User General Referral rewards (to be implemented in the future)

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
        @param  newReferralRouter Address that will add referral rewards_

### removeApprovedCtrs

```solidity
function removeApprovedCtrs(address oldReferralRouter) external
```

### setRewardToken

```solidity
function setRewardToken(address newToken) external
```

### setHestyAccessControlCtr

```solidity
function setHestyAccessControlCtr(address newControl) external
```

### setNewTokenFactory

```solidity
function setNewTokenFactory(address newFactory) external
```

