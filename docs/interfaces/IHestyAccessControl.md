# Solidity API

## IHestyAccessControl

Allows Hesty Contracts to access info about global
         pauses, locks and user kyc status.

### onlyAdmin

```solidity
function onlyAdmin(address manager) external
```

### isUserKYCValid

```solidity
function isUserKYCValid(address user) external returns (bool)
```

Checks if an user has kyc approved in hesty

### isAllPaused

```solidity
function isAllPaused() external returns (bool)
```

Checks if there is a global pause

### isUserBlackListed

```solidity
function isUserBlackListed(address user) external returns (bool)
```

Checks if user is blacklisted from operating on Hesty or with
           Hesty issued property tokens

