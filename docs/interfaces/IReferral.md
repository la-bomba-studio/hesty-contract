# Solidity API

## IReferral

Allows Hesty Contracts to access info about
            referrals and the referrals revenue amount

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

### addRewards

```solidity
function addRewards(address onBehalfOf, address referrer, uint256 projectId, uint256 amount) external
```

