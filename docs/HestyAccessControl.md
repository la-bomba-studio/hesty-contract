# Solidity API

## HestyAccessControl

### kycCompleted

```solidity
mapping(address => bool) kycCompleted
```

### blackList

```solidity
mapping(address => bool) blackList
```

### onlyAdminManager

```solidity
modifier onlyAdminManager(address manager)
```

======================================

    MODIFIER FUNCTIONS

    =========================================*

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
constructor() public
```

### onlyAdmin

```solidity
function onlyAdmin(address manager) external
```

======================================

    MUTABLE FUNCTIONS

    =========================================*

### blacklistUser

```solidity
function blacklistUser(address user) external
```

Blacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer

### unBlacklistUser

```solidity
function unBlacklistUser(address user) external
```

UnBlacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer

### approveUserKYC

```solidity
function approveUserKYC(address user) external
```

Approve user KYC
                @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer

### revertUserKYC

```solidity
function revertUserKYC(address user) external
```

Revert user KYC status
      @param user The Address of the user

### pause

```solidity
function pause() external
```

Pause all Hesty Contracts
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer

### unpause

```solidity
function unpause() external
```

Unpause all Hesty Contracts
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer

### isUserKYCValid

```solidity
function isUserKYCValid(address user) external view returns (bool)
```

Returns KYC status

        @return boolean that confirms if kyc is valid or not

### isAllPaused

```solidity
function isAllPaused() external view returns (bool)
```

Returns Paused Status

        @dev This pause affects all tokens and in the future all
             the logic of the marketplace

        @return boolean that confirms if kyc is valid or not

### isUserBlackListed

```solidity
function isUserBlackListed(address user) external view returns (bool)
```

Returns user blacklist status

        @return boolean that confirms if kyc is valid or not

