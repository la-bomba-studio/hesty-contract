# Solidity API

## TokenFactory

### propertyCounter

```solidity
uint256 propertyCounter
```

### minInvAmount

```solidity
uint256 minInvAmount
```

Number of properties created until now

### property

```solidity
mapping(uint256 => struct TokenFactory.PropertyInfo) property
```

Min amount allowed to invest

### platformFee

```solidity
mapping(uint256 => uint256) platformFee
```

Stores properties info

### ownersPlatformFee

```solidity
mapping(uint256 => uint256) ownersPlatformFee
```

(Property id => fee amount) The fee charged by the platform on every investment

### propertyOwnerShare

```solidity
mapping(uint256 => uint256) propertyOwnerShare
```

The fee charged by the platform on every investment

### refFee

```solidity
mapping(uint256 => uint256) refFee
```

The amount reserved to propertyOwner

### userInvested

```solidity
mapping(address => mapping(uint256 => uint256)) userInvested
```

The referral fee acummulated by each property before completing

### CreateProperty

```solidity
event CreateProperty(uint256 id)
```

### NewMaxNumberOfRefferals

```solidity
event NewMaxNumberOfRefferals(uint256 number)
```

### FEE_BASIS_POINTS

```solidity
uint256 FEE_BASIS_POINTS
```

### OWNERS_FEE_BASIS_POINTS

```solidity
uint256 OWNERS_FEE_BASIS_POINTS
```

### REF_FEE_BASIS_POINTS

```solidity
uint256 REF_FEE_BASIS_POINTS
```

### treasury

```solidity
address treasury
```

### referralSystemCtr

```solidity
contract IReferral referralSystemCtr
```

### ctrHestyControl

```solidity
contract IHestyAccessControl ctrHestyControl
```

### maxNumberOfReferrals

```solidity
uint256 maxNumberOfReferrals
```

### maxAmountOfRefRev

```solidity
uint256 maxAmountOfRefRev
```

### initialized

```solidity
bool initialized
```

### refCtr

```solidity
contract IReferral refCtr
```

### PropertyInfo

```solidity
struct PropertyInfo {
  uint256 price;
  uint256 threshold;
  uint256 raised;
  uint256 raiseDeadline;
  uint8 payType;
  bool isCompleted;
  bool approved;
  address owner;
  address ownerExchAddr;
  address paymentToken;
  address asset;
  address revenueToken;
}
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
constructor(uint256 fee, uint256 ownersFee, uint256 refFee_, address treasury_, uint256 minInvAmount_, address ctrHestyControl_, address refCtr_) public
```

### initialize

```solidity
function initialize(address referralSystemCtr_) external
```

### createProperty

```solidity
function createProperty(uint256 amount, uint256 tokenPrice, uint256 threshold, uint256 raiseEnd, uint8 payType, address paymentToken, address revenueToken, string name, string symbol, address admin) external returns (uint256)
```

@notice Issue a new property token

 @param amount The amount of tokens to issue
 @param tokenPrice Token Price
 @param threshold Amount to reach in order to proceed to production
 @param raiseEnd when the raise ends
 @param payType Type of dividends payment

### buyTokens

```solidity
function buyTokens(uint256 id, uint256 amount, address ref) external payable
```

Function to buy property tokens

_If there is a referral store the fee to pay and transfer funds to this contract_

### referralRewards

```solidity
function referralRewards(address ref, uint256 boughtTokensPrice, uint256 id) internal
```

### distributeRevenue

```solidity
function distributeRevenue(uint256 id, uint256 amount) external
```

### withdrawAssets

```solidity
function withdrawAssets(uint256 id) external
```

### recoverFundsInvested

```solidity
function recoverFundsInvested(uint256 id) external
```

### adminDistributeRevenue

```solidity
function adminDistributeRevenue(uint256 id, uint256 amount) external
```

@notice Admin Distribution of Property Revenue

  @param id Property Id
  @param amount Amount of EURC to distribute through property token holders

### adminBuyTokens

```solidity
function adminBuyTokens(uint256 id, address buyer, uint256 amount) external
```

### isRefClaimable

```solidity
function isRefClaimable(uint256 id) external view returns (bool)
```

Checks if people can claim their referral share of a property

### getPropertyToken

```solidity
function getPropertyToken(uint256 id) external view returns (address)
```

### completeRaise

```solidity
function completeRaise(uint256 id) external
```

Function to complete the property Raise

_Send funds to property owner exchange address and fees to
            platform multisig_

### approveProperty

```solidity
function approveProperty(uint256 id) external
```

### setPlatformFee

```solidity
function setPlatformFee(uint256 newFee) external
```

Function to change platform fee

_Fee must be lower than total amount raised_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newFee | uint256 | New platform fee |

### setRefFee

```solidity
function setRefFee(uint256 newFee) external
```

Function to change referral fee

_Fee must be lower than fee charged by platform_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newFee | uint256 | New referral fee |

### setNewPropertyOwnerReceiverAddress

```solidity
function setNewPropertyOwnerReceiverAddress(uint256 id, address newAddress) external
```

Function to change referral fee

_Fee must be lower than fee charged by platform_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 |  |
| newAddress | address | New Property Owner Address |

### extendRaiseForProperty

```solidity
function extendRaiseForProperty(uint256 id, uint256 newDeadline) external
```

Function to extend property raise deadline

### setMinInvAmount

```solidity
function setMinInvAmount(uint256 newMinInv) external
```

Function to set minimum investment amount

### setMaxNumberOfReferrals

```solidity
function setMaxNumberOfReferrals(uint256 newMax) external
```

### setTreasury

```solidity
function setTreasury(address newTreasury) external
```

