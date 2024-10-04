# Solidity API

## IReferral

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

Returns user referral numbers and revenue

### addRewards

```solidity
function addRewards(address onBehalfOf, address referrer, uint256 projectId, uint256 amount) external
```

Adds referral rewards to the user claim indexed to a property

### addGlobalRewards

```solidity
function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external
```

Adds referral rewards to the user claim not indexed to a property

### claimPropertyRewards

```solidity
function claimPropertyRewards(address user, uint256 projectId) external
```

### claimGlobalRewards

```solidity
function claimGlobalRewards(address user) external
```

