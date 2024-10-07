# Solidity API

## IHestyAccessControl

### onlyAdmin

```solidity
function onlyAdmin(address manager) external
```

Require that only admins call this function

### onlyFundsManager

```solidity
function onlyFundsManager(address manager) external
```

Require that only funds manager call this function

### kycCompleted

```solidity
function kycCompleted(address user) external returns (bool)
```

Checks if an user has kyc approved in hesty

### paused

```solidity
function paused() external view returns (bool)
```

Checks if there is a global pause

### blackList

```solidity
function blackList(address user) external returns (bool)
```

Checks if user is blacklisted from operating on Hesty or with
        Hesty issued property tokens

