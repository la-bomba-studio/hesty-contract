# Solidity API

## Constants

### BASIS_POINTS

```solidity
uint256 BASIS_POINTS
```

Math Helper to get percentages amounts

### WAD

```solidity
uint256 WAD
```

Math Helper for getting EURC power of decimals

### TEN_POWER_FIFTEEN

```solidity
uint256 TEN_POWER_FIFTEEN
```

### MULTIPLIER

```solidity
uint128 MULTIPLIER
```

Multiplier to guarantee math precision safety, is does not ensure 100% but
            the rest is neglectable as EURC has only 6 decimals

### BLACKLIST_MANAGER

```solidity
bytes32 BLACKLIST_MANAGER
```

Role than can blacklist addresses

_Secuirty Level: 3_

### FUNDS_MANAGER

```solidity
bytes32 FUNDS_MANAGER
```

Role that synchoronizes offchain investment

_Secuirty Level: 1_

### KYC_MANAGER

```solidity
bytes32 KYC_MANAGER
```

Role that approves users KYC done

_Secuirty Level: 3_

### PAUSER_MANAGER

```solidity
bytes32 PAUSER_MANAGER
```

Role that can pause transfers

_Secuirty Level: 2_

