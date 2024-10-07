# Solidity API

## PropertyToken

### rewardAsset

```solidity
contract IERC20 rewardAsset
```

### ctrHestyControl

```solidity
contract IHestyAccessControl ctrHestyControl
```

### dividendPerToken

```solidity
uint256 dividendPerToken
```

### xDividendPerToken

```solidity
mapping(address => uint256) xDividendPerToken
```

### onlyPauser

```solidity
modifier onlyPauser(address manager)
```

_Checks that onlyPauser can call the function_

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

_Checks that `user` is not blacklisted_

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

_Checks that `user` has KYC approved_

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

_Checks that hesty contracts are not all paused_

### constructor

```solidity
constructor(address tokenManagerContract_, uint256 initialSupply_, string name_, string symbol_, address rewardAsset_, address ctrHestyControl_) public
```

_Mints initialSupply_ * 1 ether of tokens and transfers them
                to Token Factory
        @param  tokenManagerContract_ Contract that will manage initial issued supply
        @param  initialSupply_ Initial Property Token Supply
        @param  name_ Token Name
        @param  symbol_ Token Symbol/Ticker
        @param  rewardAsset_ Token that will distributed through holders has an investment return (EURC)
        @param  ctrHestyControl_ Contract that has the power to manage access to the token

See {ERC20-constructor}._

### distributionRewards

```solidity
function distributionRewards(uint256 amount) external
```

_Claims users dividends
        @param  amount Token Amount that users wants to buy_

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

_Pauses Property Token Only_

### unpause

```solidity
function unpause() external
```

_Unpauses Property Token Only_

