# Solidity API

## PropertyToken

Token associated to a property that tracks
            investors and stakeholders that are entitled
            to a share of the property generated revenue.

_{ERC20} token, including:

         - Pre minted initial supply
         - Ability for holders to burn (destroy) their tokens
         - No access control mechanism (for minting/pausing) and hence no governance_

### dividendPerToken

```solidity
uint256 dividendPerToken
```

Multiplier to guarantee math safety in gwei, everything else is neglectable

### xDividendPerToken

```solidity
mapping(address => uint256) xDividendPerToken
```

Dividends per share/token

### ctrHestyControl

```solidity
address ctrHestyControl
```

Last user dividends essential to calculate future rewards

### rewardAsset

```solidity
contract IERC20 rewardAsset
```

### onlyPauser

```solidity
modifier onlyPauser(address manager)
```

======================================

    MODIFIER FUNCTIONS

    =========================================*

### onlyBlackLister

```solidity
modifier onlyBlackLister(address manager)
```

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

### constructor

```solidity
constructor(address tokenManagerContract_, uint256 initialSupply_, string name_, string symbol_, address rewardAsset_, address ctrHestyControl_) public
```

_Mints initialSupply_ * 1 ether of tokens and transfers them
           to Token Factory

See {ERC20-constructor}._

### distributionRewards

```solidity
function distributionRewards(uint256 amount) external
```

Claims users dividends
      @param amount Token Amount that users wants to buy

### claimDividensExternal

```solidity
function claimDividensExternal(address user) external
```

Claims users dividends
      @param  user User Address that will receive dividends

### transfer

```solidity
function transfer(address to, uint256 amount) public returns (bool)
```

_Transfers users tokens from address msg.sender
           to address "to" using openzepplin standard
           but implements two internal Hesty mechanism:

           - A KYC requirement
           - Claims dividends to both addresses involved in
             in the transfer before transfer is completed
             to avoid math overhead

See {ERC20-constructor}._

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) public returns (bool)
```

_Transfers users tokens from address "from"
           to address "to" using openzepplin standard
           but implements multiple internal Hesty mechanism:

           - A KYC requirement
           - A blacklist requirement
           - Claims dividends to both addresses involved in
             in the transfer before transfer is completed
             to avoid math overhead
            This function implements two types of pause
            an unique pause and a pause dependent on HestyAccessControl

See {ERC20-constructor}._

### pause

```solidity
function pause() external
```

### unpause

```solidity
function unpause() external
```

