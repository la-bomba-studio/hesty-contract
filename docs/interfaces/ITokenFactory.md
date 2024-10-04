# Solidity API

## ITokenFactory

### adminBuyTokens

```solidity
function adminBuyTokens(uint256 id, address buyer, uint256 amount) external
```

Buy Tokens for users that acquired them off chain through EURO (FIAT)

### distributeRevenue

```solidity
function distributeRevenue(uint256 id, uint256 amount) external
```

Distribute Revenue through

### isRefClaimable

```solidity
function isRefClaimable(uint256 id) external view returns (bool)
```

Return if it is already possible to claim referral revenue of a property

