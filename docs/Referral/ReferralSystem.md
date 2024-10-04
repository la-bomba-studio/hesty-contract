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

Hesty Global Access Control

### tokenFactory

```solidity
contract ITokenFactory tokenFactory
```

Token contract address of rewards

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

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

Approved addresses that can add property rewards

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

### constructor

```solidity
constructor(address rewardToken_, address ctrHestyControl_, address tokenFactory_) public
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
function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external
```

Adds referral rewards to the user claim not indexed to a property

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

_Return Number of user referrals and user referral revenues_

### setRewardToken

```solidity
function setRewardToken(address newToken) external
```

