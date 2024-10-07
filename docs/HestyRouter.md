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
constructor(address tokenFactory_, address hestyAccessControl_) public
```

_Hesty Router Constructor
        @param  tokenFactory_ Token Factory Contract
        @param  hestyAccessControl_ Hesty Access Control Contract_

### onlyAdmin

```solidity
modifier onlyAdmin()
```

_Checks that `msg.sender` is an Admin_

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

### setHestyAccessControlCtr

```solidity
function setHestyAccessControlCtr(address newControl) external
```

_Set Hesty Access Control Contract
        @param  newControl Hesty Access Control Contract_

### setNewTokenFactory

```solidity
function setNewTokenFactory(address newFactory) external
```

_Set New Token Factory
        @param  newFactory New Token Factory_

