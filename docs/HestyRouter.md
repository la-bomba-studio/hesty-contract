# Solidity API

## HestyRouter

### tokenFactory

```solidity
contract ITokenFactory tokenFactory
```

### hestyAccessControl

```solidity
contract IHestyAccessControl hestyAccessControl
```

### onlyAdmin

```solidity
modifier onlyAdmin()
```

### onlyBlackListManager

```solidity
modifier onlyBlackListManager(address manager)
```

### onlyKYCManager

```solidity
modifier onlyKYCManager(address manager)
```

### onlyPauserManager

```solidity
modifier onlyPauserManager(address manager)
```

### constructor

```solidity
constructor(address tokenFactory_, address hestyAccessControl_) public
```

### adminDistribution

```solidity
function adminDistribution(uint256 propertyId, uint256 amount) external
```

_Distribute Rewards that were paid in EURO and converted to EURC
             through custodian
        @param propertyId The property Id
        @param amount Amount of funds to distribute_

### offChainBuyTokens

```solidity
function offChainBuyTokens(uint256 propertyId, address onBehalfOf, uint256 amount) external
```

_Buy Tokens for users that paid in FIAT currency (EUR)
        @param  propertyId The property Id
        @param  onBehalfOf The user address of who bought with FIAT
        @param  amount Amount of funds to distribute_

### revertUserBuyTokens

```solidity
function revertUserBuyTokens() external
```

