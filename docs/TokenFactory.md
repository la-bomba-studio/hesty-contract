# Solidity API

## TokenFactory

### ctrHestyControl

```solidity
contract IHestyAccessControl ctrHestyControl
```

### referralSystemCtr

```solidity
contract IReferral referralSystemCtr
```

### propertyCounter

```solidity
uint256 propertyCounter
```

### minInvAmount

```solidity
uint256 minInvAmount
```

### maxNumberOfReferrals

```solidity
uint256 maxNumberOfReferrals
```

### maxAmountOfRefRev

```solidity
uint256 maxAmountOfRefRev
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

### initialized

```solidity
bool initialized
```

### property

```solidity
mapping(uint256 => struct TokenFactory.PropertyInfo) property
```

### platformFee

```solidity
mapping(uint256 => uint256) platformFee
```

### ownersPlatformFee

```solidity
mapping(uint256 => uint256) ownersPlatformFee
```

### propertyOwnerShare

```solidity
mapping(uint256 => uint256) propertyOwnerShare
```

### refFee

```solidity
mapping(uint256 => uint256) refFee
```

### userInvested

```solidity
mapping(address => mapping(uint256 => uint256)) userInvested
```

### InitializeFactory

```solidity
event InitializeFactory(address referralCtr)
```

### CreateProperty

```solidity
event CreateProperty(uint256 id)
```

### NewMaxNumberOfReferrals

```solidity
event NewMaxNumberOfReferrals(uint256 number)
```

### NewMaxAmountOfRefRev

```solidity
event NewMaxAmountOfRefRev(uint256 number)
```

### NewReferralSystemCtr

```solidity
event NewReferralSystemCtr(address newSystemCtr)
```

### NewTreasury

```solidity
event NewTreasury(address newTreasury)
```

### NewMinInvestmentLimit

```solidity
event NewMinInvestmentLimit(uint256 newLimit)
```

### NewPropertyOwnerAddrReceiver

```solidity
event NewPropertyOwnerAddrReceiver(address newAddress)
```

### NewInvestment

```solidity
event NewInvestment(uint256 propertyId, address investor, uint256 amount, uint256 date)
```

### RevenuePayment

```solidity
event RevenuePayment(uint256 propertyId, uint256 amount)
```

### CancelProperty

```solidity
event CancelProperty(uint256 propertyId)
```

### NewPlatformFee

```solidity
event NewPlatformFee(uint256 newFee)
```

### NewOwnersFee

```solidity
event NewOwnersFee(uint256 newFee)
```

### ClaimProfits

```solidity
event ClaimProfits(address user, uint256 propertyId)
```

### CompleteRaise

```solidity
event CompleteRaise(uint256 propertyId)
```

### RecoverFunds

```solidity
event RecoverFunds(address user, uint256 propertyId)
```

### ApproveProperty

```solidity
event ApproveProperty(uint256 propertyId)
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

### constructor

```solidity
constructor(uint256 fee, uint256 ownersFee, uint256 refFee_, address treasury_, uint256 minInvAmount_, address ctrHestyControl_) public
```

_Constructor for Token Factory
        @param  fee Investment fee charged by Hesty (in Basis Points)
        @param  ownersFee Owner Fee charged by Hesty (in Basis Points)
        @param  refFee_ Referaal Fee charged by referrals (in Basis Points)
        @param  treasury_ The Multi-Signature Address that will receive Hesty fees revenue
        @param  minInvAmount_ Minimum amount a user can invest
        @param  ctrHestyControl_ Contract that manages access to certain functions_

### onlyAdmin

```solidity
modifier onlyAdmin()
```

_Checks that `msg.sender` is an Admin_

### onlyFundsManager

```solidity
modifier onlyFundsManager()
```

_Checks that `msg.sender` is an Admin_

### onlyWhenInitialized

```solidity
modifier onlyWhenInitialized()
```

_Checks that contract is initialized_

### whenNotBlackListed

```solidity
modifier whenNotBlackListed()
```

_Checks that `msg.sender` is not blacklisted_

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

_Checks that `msg.sender` has is KYC approved_

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

_Checks that contracts are not paused_

### idMustBeValid

```solidity
modifier idMustBeValid(uint256 id)
```

_Checks if property id is valid_

### initialize

```solidity
function initialize(address referralSystemCtr_) external
```

_Initialized Token Factory Contract
        @dev    It emits a `InitializeFactory` event.
        @param  referralSystemCtr_ Referral System Contract that manages referrals rewards_

### createProperty

```solidity
function createProperty(uint256 amount, uint256 tokenPrice, uint256 threshold, uint8 payType, address paymentToken, address revenueToken, string name, string symbol, address admin) external returns (uint256)
```

Issues a new property token
        @dev    It emits a `CreateProperty` event.
        @param  amount The amount of tokens to issue
        @param  tokenPrice Token Price
        @param  threshold Amount to reach in order to proceed to production
        @param  payType Type of dividends payment
        @param  paymentToken Token that will be charged on every investment made

### buyTokens

```solidity
function buyTokens(address onBehalfOf, uint256 id, uint256 amount, address ref) external
```

_Function to buy property tokens
        @dev    If there is a referral store the fee to pay and transfer funds to this contract
        @param  id Property id
        @param  amount Amount of tokens that user wants to buy
        @param  ref The referral of the user, address(0) if doesn't exist_

### referralRewards

```solidity
function referralRewards(address onBehalfOf, address ref, uint256 boughtTokensPrice, uint256 id) internal
```

_Function that tries to add referral rewards
        @param  ref user that referenced the buyer
        @param  boughtTokensPrice Amount invested by buyer_

### distributeRevenue

```solidity
function distributeRevenue(uint256 id, uint256 amount) external
```

### claimInvestmentReturns

```solidity
function claimInvestmentReturns(uint256 id) external
```

### recoverFundsInvested

```solidity
function recoverFundsInvested(uint256 id) external
```

### adminBuyTokens

```solidity
function adminBuyTokens(uint256 id, address buyer, uint256 amount) external
```

### isRefClaimable

```solidity
function isRefClaimable(uint256 id) external view returns (bool)
```

_Checks if people can claim their referral share of a property
        @return If it is already possible to claim referral rewards_

### getPropertyInfo

```solidity
function getPropertyInfo(uint256 id) external view returns (address, address)
```

_Returns Property representative token
        @param id Property Id
        @return Property Token_

### completeRaise

```solidity
function completeRaise(uint256 id) external
```

_Function to complete the property Raise
        @dev    It emits a `CompleteRaise` event.
        @dev    Send funds to property owner exchange address and fees to
                platform multisig_

### approveProperty

```solidity
function approveProperty(uint256 id, uint256 raiseDeadline) external
```

_Approves property to start raise
        @dev     It emits an `ApproveProperty` event.
        @param   id Property Id_

### cancelProperty

```solidity
function cancelProperty(uint256 id) external
```

_In case Hesty or property Manager gives up from raising funds for property
                 allow users to claim back their funds
        @dev     It emits a `CancelProperty` event.
        @param   id Property Id_

### setPlatformFee

```solidity
function setPlatformFee(uint256 newFee) external
```

_Function to change platform fee
        @dev     It emits a `NewPlatformFee` event.
        @dev     Fee must be lower than total amount raised
        @param   newFee New platform fee_

### setOwnersFee

```solidity
function setOwnersFee(uint256 newFee) external
```

_Function to change owners fee
        @dev     It emits a `NewOwnersFee` event.
        @dev     Fee must be lower than total amount raised
        @param   newFee New owners fee_

### setRefFee

```solidity
function setRefFee(uint256 newFee) external
```

_Function to change referral fee
        @dev   Fee must be lower than fee charged by platform
        @param newFee New referral fee_

### setNewPropertyOwnerReceiverAddress

```solidity
function setNewPropertyOwnerReceiverAddress(uint256 id, address newAddress) external
```

_Function to change owners address where he will receive funds
        @dev    It emits a `NewPropertyOwnerAddrReceiver` event.
        @dev    Fee must be lower than fee charged by platform
        @param  id Property Id
        @param  newAddress New Property Owner Address_

### extendRaiseForProperty

```solidity
function extendRaiseForProperty(uint256 id, uint256 newDeadline) external
```

Function to extend property raise deadline

### setMinInvAmount

```solidity
function setMinInvAmount(uint256 newMinInv) external
```

_Function to set minimum investment amount
        @dev    It emits a `NewMinInvestmentLimit` event.
        @param  newMinInv Minimum Investment Amount_

### setMaxNumberOfReferrals

```solidity
function setMaxNumberOfReferrals(uint256 newMax) external
```

_Function to set the maximum number of referrals a user can have
        @dev    It emits a `NewMaxNumberOfReferrals` event.
        @param  newMax Maximum number of referrals_

### setMaxAmountOfRefRev

```solidity
function setMaxAmountOfRefRev(uint256 newMax) external
```

_Function to set the maximum amount of referral revenue
        @dev    It emits a `NewMaxAmountOfRefRev` event.
        @param  newMax Maximum amount of revenue_

### setTreasury

```solidity
function setTreasury(address newTreasury) external
```

_Function to set a new treasury address
        @dev    It emits a `NewTreasury` event.
        @param  newTreasury The new treasury address_

### setReferralContract

```solidity
function setReferralContract(address newReferralContract) external
```

_Function to set a new Referral Management Contract
        @dev    It emits a `NewReferralSystemCtr` event.
        @param  newReferralContract The new Referral Management Contract_

