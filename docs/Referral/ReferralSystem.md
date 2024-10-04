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

### refferedBy

```solidity
mapping(address => address) refferedBy
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

### addRewards

```solidity
function addRewards(address onBehalfOf, address user, uint256 projectId, uint256 amount) external
```

@notice Add Rewards Associated to a Property Project
  @param onBehalfOf User who referred and the one that will receive the income
  @param user The user who were referenced by onBehalfOf user
  @param projectId The Property project
  @param amount The amount of rewards

### addGlobalRewards

```solidity
function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external
```

### claimPropertyRewards

```solidity
function claimPropertyRewards(address user, uint256 projectId) external
```

### claimGlobalRewards

```solidity
function claimGlobalRewards(address user) external
```

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

J

### setRewardToken

```solidity
function setRewardToken(address newToken) external
```

