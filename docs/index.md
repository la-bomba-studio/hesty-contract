# Solidity API

## Constants

### BASIS_POINTS

```solidity
uint256 BASIS_POINTS
```

Math Helper to get percentages amounts

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

## HestyRouter

### onlyAdmin

```solidity
modifier onlyAdmin(address manager)
```

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

### distribute

```solidity
function distribute() external
```

### offChainBuyTokens

```solidity
function offChainBuyTokens() external
```

### revertUserBuyTokens

```solidity
function revertUserBuyTokens() external
```

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

## ReferralSystem

### ctrHestyControl

```solidity
contract IHestyAccessControl ctrHestyControl
```

### rewardToken

```solidity
address rewardToken
```

Hesty Global Access Control

### tokenFactory

```solidity
contract ITokenFactory tokenFactory
```

Token contract address of rewards

### rewards

```solidity
mapping(address => mapping(uint256 => uint256)) rewards
```

### totalRewards

```solidity
mapping(address => uint256) totalRewards
```

Rewards earned by user indexed to each property

### globalRewards

```solidity
mapping(address => uint256) globalRewards
```

Total rewards earned by user indexed to properties

### rewardsByProperty

```solidity
mapping(uint256 => uint256) rewardsByProperty
```

Total rewards earned by user not indexed to properties

### numberOfRef

```solidity
mapping(address => uint256) numberOfRef
```

Total rewards earned by users filtered by property

### refferedBy

```solidity
mapping(address => address) refferedBy
```

Number of referrals a user has

### approvedCtrs

```solidity
mapping(address => bool) approvedCtrs
```

Who reffered the user

### whenNotAllPaused

```solidity
modifier whenNotAllPaused()
```

Approved addresses that can add property rewards

### whenKYCApproved

```solidity
modifier whenKYCApproved(address user)
```

### whenNotBlackListed

```solidity
modifier whenNotBlackListed(address user)
```

### constructor

```solidity
constructor(address rewardToken_, address ctrHestyControl_, address tokenFactory_) public
```

### addRewards

```solidity
function addRewards(address onBehalfOf, address user, uint256 projectId, uint256 amount) external
```

@notice Add Rewards Associated to a Property Project
  @param onBehalfOf User who referred and the one that will receive the income
  @param user The user who were referenced by onBehalfOf user
  @param projectId The Property project
  @param amount The amount of rewards

### addGlobalRewards

```solidity
function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external
```

### claimPropertyRewards

```solidity
function claimPropertyRewards(address user, uint256 projectId) external
```

### claimGlobalRewards

```solidity
function claimGlobalRewards(address user) external
```

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

J

### setRewardToken

```solidity
function setRewardToken(address newToken) external
```

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

## IReferral

Allows Hesty Contracts to access info about
            referrals and the referrals revenue amount

### getReferrerDetails

```solidity
function getReferrerDetails(address user) external view returns (uint256, uint256, uint256)
```

### addRewards

```solidity
function addRewards(address onBehalfOf, address referrer, uint256 projectId, uint256 amount) external
```

## ITokenFactory

### distributeRevenue

```solidity
function distributeRevenue(uint256 id, uint256 amount) external
```

### isRefClaimable

```solidity
function isRefClaimable(uint256 id) external view returns (bool)
```

