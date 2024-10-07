# Solidity API

## HestyAccessControl

### initialSponsorAmount

```solidity
uint256 initialSponsorAmount
```

### kycCompleted

```solidity
mapping(address => bool) kycCompleted
```

Checks if an user is KYC approved in hesty

### blackList

```solidity
mapping(address => bool) blackList
```

Checks if user is blacklisted from operating on Hesty or with
        Hesty issued property tokens

### constructor

```solidity
constructor() public
```

### onlyAdminManager

```solidity
modifier onlyAdminManager(address manager)
```

_Checks that `manager` is an Admin_

### onlyFundManager

```solidity
modifier onlyFundManager(address manager)
```

_Checks that `manager` is funds manger_

### onlyBlackListManager

```solidity
modifier onlyBlackListManager(address manager)
```

_Checks that `manager` is blackListManager_

### onlyKYCManager

```solidity
modifier onlyKYCManager(address manager)
```

_Checks that `manager` is KYC manager_

### onlyPauserManager

```solidity
modifier onlyPauserManager(address manager)
```

_Checks that `manager` is pauser manger_

### onlyAdmin

```solidity
function onlyAdmin(address manager) external
```

Only Admin
        @param  manager The user that wants to call the function
                onlyOnwer

### onlyFundsManager

```solidity
function onlyFundsManager(address manager) external
```

Only Funds Manager
        @param  manager The user that wants to call the function
                onlyFundManager

### blacklistUser

```solidity
function blacklistUser(address user) external
```

Blacklist user
        @param  user The Address of the user
        @dev    Require this approval to allow users move Hesty derivatives
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
             onlyOnwer, in case user has less funds than sponsor amount send a few ETH

### approveKYCOnly

```solidity
function approveKYCOnly(address user) external
```

_Approve KYC only without sponsoring address
        @param  user The Address of the user_

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

_Pause all Hesty Contracts
        @dev    Require this approval to allow users move Hesty derivatives
                onlyOnwer_

### unpause

```solidity
function unpause() external
```

_Unpause all Hesty Contracts
        @dev    Require this approval to allow users move Hesty derivatives
                onlyOnwer_

### setSponsorAmount

```solidity
function setSponsorAmount(uint256 newAmount) external
```

_Set sponsor amount
        @param newAmount New sponsor amount_

### paused

```solidity
function paused() public view returns (bool)
```

_Returns Paused Status
        @dev This pause affects all tokens and in the future all
             the logic of the marketplace
        @return boolean Checks if contracts are paused_

### receive

```solidity
receive() external payable
```

