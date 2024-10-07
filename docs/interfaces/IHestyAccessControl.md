# Solidity API

## IHestyAccessControl

### onlyAdmin

```solidity
function onlyAdmin(address manager) external
```

Require that only admins can call this function

### onlyFundsManager

```solidity
function onlyFundsManager(address manager) external
```

Require that only funds manager can call this function

### kycCompleted

```solidity
function kycCompleted(address user) external returns (bool)
```

Checks if an user is KYC approved in hesty

### paused

```solidity
function paused() external view returns (bool)
```

Checks if there is a global pause of Hesty Contracts

### blackList

```solidity
function blackList(address user) external returns (bool)
```

Checks if user is blacklisted from operating on Hesty or with
        Hesty issued property tokens

