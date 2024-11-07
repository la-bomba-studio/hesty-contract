// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PropertyToken} from "./PropertyToken.sol";
import "./interfaces/ITokenFactory.sol";
import "./interfaces/IReferral.sol";
import "./interfaces/IHestyAccessControl.sol";
import "./Constants.sol";

/*

    @title Token Factory

    @notice Manages issuance of property tokens, stores them until they are bought
            and manages the distribution of revenue through holders. Allows
            investors to also claim the investment returns.
            In case the property fails to raise then allows users to claim
            funds back.

    @author Pedro G. S. Ferreira

    .##.....##.########.########.#########.##....##.
    .##.....##.##.......##..........##......##..##.
    .##.....##.##.........##........##........##.
    .#########.########.....##......##........##.
    .##.....##.##..........##.......##........##.
    .##.....##.##.........##........##........##.
    .##.....##.########.########....##........##.

*/

contract TokenFactory is
ReentrancyGuard,
Constants {

    IHestyAccessControl public ctrHestyControl;     // Hesty Access Control Contract
    IReferral           public referralSystemCtr;   // Referral System Contract

    uint256 public propertyCounter;         // Number of properties created until now
    uint256 public minInvAmount;            // Minimum amount allowed to invest
    uint256 public maxNumberOfReferrals;    // Maximum Number of Referrals that a user can have
    uint256 public maxAmountOfRefRev;       // Maximum Amount of Referral Revenue users can earn
    uint256 public FEE_BASIS_POINTS;        // Investment Fee charged by Hesty (in Basis Points)
    uint256 public REF_FEE_BASIS_POINTS;    // Referral Fee charged by referrals (in Basis Points)
    address public treasury;                // Address that will receive Hesty fees revenue
    bool    public initialized;             // Checks if the contract is already initialized


    mapping(uint256 => PropertyInfo)    public property;                // Stores properties info
    mapping(uint256 => uint256)         public platformFee;             // (Property id => fee amount) The fee earned by the platform on every investment
    mapping(uint256 => uint256)         public ownersPlatformFee;       // The fee earned by the platform on every investment
    mapping(uint256 => uint256)         public propertyOwnerShare;      // The amount reserved to propertyOwner
    mapping(uint256 => uint256)         public refFee;                  // The referral fee accumulated by each property before completing
    mapping(uint256 => uint256)         public OWNERS_FEE_BASIS_POINTS; // Owners Fee charged by Hesty (in Basis Points) in each project

    mapping(address => mapping(uint256 => uint256)) public userInvested;    // Amount invested by each user in each property
    mapping(address => mapping(uint256 => uint256)) public rightForTokens;  // Amount of tokens that each user bought


    //Event
    event              InitializeFactory(address referralCtr);
    event                 CreateProperty(uint256 id);
    event           NewReferralSystemCtr(address newSystemCtr);
    event                    NewTreasury(address newTreasury);
    event   NewPropertyOwnerAddrReceiver(address newAddress);
    event                  NewInvestment(uint256 indexed propertyId, address investor, uint256 amount, uint256 date);
    event                 RevenuePayment(uint256 indexed propertyId, uint256 amount);
    event                 CancelProperty(uint256 propertyId);
    event                 NewPlatformFee(uint256 newFee);
    event                   NewOwnersFee(uint256 indexed id, uint256 newFee);
    event                   ClaimProfits(address indexed user, uint256 propertyId);
    event                  CompleteRaise(uint256 propertyId);
    event                   RecoverFunds(address indexed user, uint256 propertyId);
    event                ApproveProperty(uint256 propertyId);
    event            GetInvestmentTokens(address indexed user, uint256 propertyId);


    struct PropertyInfo{
        uint256 price;          // Price for each property token
        uint256 threshold;      // Amount necessary to proceed with investment
        uint256 raised;         // Amount raised until now
        uint256 raiseDeadline;  // When the fundraising ends
        bool    isCompleted;    // Checks if the raise is completed
        bool    approved;       // Checks if the raise can start
        address owner;          // Property Manager/owner
        address ownerExchAddr;  // Property Owner/Manager exchange address to receive euroc
        address paymentToken;   // Token used to buy property tokens/assets
        address asset;          // Property token contract
        address revenueToken;   // Revenue token for investors

    }

    /**
        @dev    Constructor for Token Factory
        @param  fee Investment fee charged by Hesty (in Basis Points)
        @param  refFee_ Referral Fee charged by referrals (in Basis Points)
        @param  treasury_ The Multi-Signature Address that will receive Hesty fees revenue
        @param  minInvAmount_ Minimum amount a user can invest
        @param  ctrHestyControl_ Contract that manages access to certain functions
    */
    constructor(
        uint256 fee,
        uint256 refFee_,
        address treasury_,
        uint256 minInvAmount_,
        address ctrHestyControl_
    ){

        require(refFee_ < fee, "Ref fee invalid");
        require(fee < BASIS_POINTS, "Invalid Platform Fee");

        FEE_BASIS_POINTS        = fee;
        REF_FEE_BASIS_POINTS    = refFee_;
        minInvAmount            = minInvAmount_;
        treasury                = treasury_;
        maxNumberOfReferrals    = 20;               // Start with max 20 referrals
        maxAmountOfRefRev       = 10000 * WAD;      // Start with max 10000€ of revenue
        initialized             = false;
        ctrHestyControl         = IHestyAccessControl(ctrHestyControl_);

    }

    /**
        @dev Checks that `msg.sender` is an Admin
    */
    modifier onlyAdmin(){
        ctrHestyControl.onlyAdmin(msg.sender);
        _;
    }

    /**
        @dev Checks that `msg.sender` is an Admin
    */
    modifier onlyFundsManager(){
        ctrHestyControl.onlyFundsManager(msg.sender);
        _;
    }

    /**
        @dev Checks that contract is initialized
    */
    modifier onlyWhenInitialized(){
        require(initialized, "Not yet init");
        _;
    }

    /**
        @dev Checks that `msg.sender` is not blacklisted
    */
    modifier whenNotBlackListed(){
        require(!ctrHestyControl.blackList(msg.sender), "Blacklisted");
        _;
    }

    /**
        @dev Checks that `msg.sender` has is KYC approved
    */
    modifier whenKYCApproved(address user){
        require(ctrHestyControl.kycCompleted(user), "No KYC Made");
        _;
    }

    /**
        @dev Checks that contracts are not paused
    */
    modifier whenNotAllPaused(){
        require(!ctrHestyControl.paused(), "All Hesty Paused");
        _;
    }

    /**
        @dev Checks if property id is valid
    */
    modifier idMustBeValid(uint256 id){
        require(id < propertyCounter, "Id must be valid");
        _;
    }

    /**
        @dev    Initialized Token Factory Contract
        @dev    It emits a `InitializeFactory` event.
        @param  referralSystemCtr_ Referral System Contract that manages referrals rewards
    */
    function initialize(address referralSystemCtr_) external onlyAdmin{

        require(!initialized, "Already init");

        initialized       = true;
        referralSystemCtr = IReferral(referralSystemCtr_);

        emit InitializeFactory(referralSystemCtr_);

    }

    /**===================================================
        NON OWNER STATE MODIFIABLE FUNTIONS
    ======================================================**/

    /**
        @dev    Issues a new property token
        @dev    It emits a `CreateProperty` event.
        @param  amount The amount of tokens to issue
        @param  tokenPrice Token Price
        @param  threshold Amount to reach in order to proceed to production
        @param  paymentToken Token that will be charged on every investment made
    */
    function createProperty(
        uint256 amount,
        uint256 listingTokenFee,
        uint tokenPrice,
        uint256 threshold,
        address paymentToken,
        address revenueToken,
        string memory name,
        string memory symbol,
        address admin
    ) external whenKYCApproved(msg.sender) whenNotAllPaused whenNotBlackListed returns(uint256) {

        require(paymentToken != address(0) && revenueToken != address(0), "Invalid pay token");
        require( listingTokenFee < BASIS_POINTS, "Fee must be valid");

        address newAsset = address(
                            new PropertyToken(address(this),
                                                    amount,
                                                    name,
                                                    symbol,
                                                    revenueToken,
                                                    admin));

        property[propertyCounter++] = PropertyInfo( tokenPrice,
                                                    threshold,
                                                    0,
                                                    0,
                                                    false,
                                                    false,
                                                    msg.sender,
                                                    msg.sender,
                                                    paymentToken,
                                                    newAsset,
                                                    revenueToken);

        OWNERS_FEE_BASIS_POINTS[propertyCounter - 1] = listingTokenFee;

        emit CreateProperty(propertyCounter - 1);

        return propertyCounter - 1;
    }


    /**
        @dev    Function to buy property tokens
        @dev    It emits a `NewInvestment` event.
        @dev    If there is a referral store the fee to pay and transfer funds to this contract
        @param  id Property id
        @param  amount Amount of tokens that user wants to buy
        @param  ref The referral of the user, address(0) if doesn't exist
    */
    function buyTokens(
        address onBehalfOf,
        uint256 id,
        uint256 amount,
        address ref
    ) external nonReentrant onlyWhenInitialized whenNotAllPaused {

        PropertyInfo storage p = property[id];

        // Require that raise is still active and not expired
        require(p.raiseDeadline >= block.timestamp, "Raise expired");
        require(amount >= minInvAmount, "Lower than min");
        require(property[id].approved, "Property Not For Sale");
        require(!property[id].isCompleted, "Property Sale Completed");

        // Calculate how much costs to buy tokens and
        // Calculate the investment fee and then get the total investment cost
        uint256 boughtTokensPrice = amount * p.price;
        uint256 fee               = boughtTokensPrice * FEE_BASIS_POINTS / BASIS_POINTS;
        uint256 total             = boughtTokensPrice + fee;

        // Charge investment cost from user
        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        // Store Platform fee and user Invested Amount Paid
        platformFee[id]                += fee;
        userInvested[msg.sender][id]   += boughtTokensPrice;
        rightForTokens[onBehalfOf][id] += amount;

        /// @dev Calculate owners fee
        uint256 ownersFee = boughtTokensPrice * OWNERS_FEE_BASIS_POINTS[id] / BASIS_POINTS;

        ownersPlatformFee[id]  += ownersFee;
        propertyOwnerShare[id] += boughtTokensPrice - ownersFee;

        // Add Referral rewards in the referralSystemCtr
        referralRewards(onBehalfOf, ref, boughtTokensPrice, id);

        p.raised     += boughtTokensPrice;
        property[id] = p;

        emit NewInvestment(id, onBehalfOf, boughtTokensPrice, block.timestamp);
    }

    /**
        @dev    Function that tries to add referral rewards
        @param  ref user that referenced the buyer
        @param  boughtTokensPrice Amount invested by buyer
    */
    function referralRewards(address onBehalfOf, address ref, uint256 boughtTokensPrice, uint256 id) internal{

        if(ref != address(0)){

            (uint256 userNumberRefs,uint256 userRevenue,) = referralSystemCtr.getReferrerDetails(ref);

            uint256 refFee_ = boughtTokensPrice * REF_FEE_BASIS_POINTS / BASIS_POINTS;

            // maxAmountOfRefRev can be lowered and userevenue may be higher than
            // maxAmountOfRefRev after that, causing maxAmountOfRefRev - userRevenue to be negative
            maxAmountOfRefRev = (maxAmountOfRefRev >= userRevenue ) ? maxAmountOfRefRev : userRevenue;

            refFee_ = (userRevenue + refFee_ > maxAmountOfRefRev) ? maxAmountOfRefRev - userRevenue : refFee_;


            /// @dev maxNumberOfReferral = 20 && maxAmountOfRefRev = €10000
            if(userNumberRefs < maxNumberOfReferrals && refFee_ > 0){

                // Try to Add Referral rewards but don't stop if it fails
                try referralSystemCtr.addRewards(ref, onBehalfOf,id, refFee_){
                    refFee[id] += refFee_;
                }catch{

                }
            }
        }
    }

    /*
        @dev    Distribution of revenue through property token holders
        @dev    It emits a `RevenuePayment` event.
        @param  id Property id
        @param  amount The amount of funds in EURC to distribute
    */
    function distributeRevenue(uint256 id, uint256 amount) external nonReentrant whenNotAllPaused{

        PropertyInfo storage p = property[id];

        require(p.isCompleted, "Time not valid");

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
        IERC20(p.revenueToken).approve(p.asset, amount);
        PropertyToken(p.asset).distributionRewards(amount);

        emit RevenuePayment(id, amount);

    }

    /*
        @dev    Get Property Tokens after property raize is complete
        @dev    It emits a `GetInvestmentTokens` event.
        @param  user User address
        @param  id Property id
    */
    function getInvestmentTokens(address user, uint256 id) external nonReentrant whenNotAllPaused{

        PropertyInfo storage p = property[id];

        require(p.isCompleted, "Time not valid");

        // Transfer Asset to buyer
        if(rightForTokens[user][id] > 0)
            IERC20(p.asset).transfer(user, rightForTokens[user][id]);

        emit GetInvestmentTokens(user, id);
    }

    /*
        @dev    Claim Investment returns
        @dev    It emits a `ClaimProfits` event.
        @param  user that will receive investment returns
        @param  id Property id
    */
    function claimInvestmentReturns(address user, uint256 id) external nonReentrant whenNotAllPaused{

        PropertyInfo storage p = property[id];

        require(p.isCompleted, "Time not valid");

        PropertyToken(p.asset).claimDividensExternal(user);

        emit ClaimProfits(user, id);
    }

    /*
        @dev    Claim Investment returns
        @dev    It emits a `RecoverFunds` event.
        @param  user that will receive recover investment
        @param  id Property id
    */
    function recoverFundsInvested(address user, uint256 id) external nonReentrant whenNotAllPaused idMustBeValid(id){

        PropertyInfo storage p = property[id];

        require(p.raiseDeadline < block.timestamp && !p.isCompleted, "Time not valid"); // @dev it must be < not <=

        uint256 amount         = userInvested[user][id];
        userInvested[user][id] = 0;

        IERC20(p.paymentToken).transfer(user, amount);

        emit RecoverFunds(user, id);

    }

    /**=====================================
        Viewable Functions
    =========================================*/

    /**
        @dev    Checks if people can claim their referral share of a property
        @param  id Property Id
        @return If it is already possible to claim referral rewards
    */
    function isRefClaimable(uint256 id) external view returns(bool){
        return property[id].threshold <= property[id].raised && property[id].isCompleted;
    }

    /**
        @dev    Returns Property representative token
        @param id Property Id
        @return Property Token
    */
    function getPropertyInfo(uint256 id) external view returns(address, address){
        return (property[id].asset, property[id].revenueToken);
    }



    /**===================================================
       OWNER STATE MODIFIABLE FUNTIONS
   ======================================================**/

    /*
        @dev    Buy Tokens without spending funds, this helpful for offchain investments
        @dev    It emits a `NewInvestment` event.
        @param  id Property id
        @param  buyer The user who will receive the property tokens
        @param  amount The amount of property tokens to buy
    */
    function adminBuyTokens(uint256 id, address buyer, uint256 amount) external nonReentrant onlyFundsManager{

        PropertyInfo storage p    = property[id];

        // Require that raise is still active and not expired
        require(p.raiseDeadline >= block.timestamp, "Raise expired");

        // Calculate how much costs to buy tokens
        uint256 boughtTokensPrice = amount * p.price;

        IERC20(p.asset).transfer(buyer, amount);

        p.raised += boughtTokensPrice;
        property[id] = p;

        emit NewInvestment(id, buyer, boughtTokensPrice, block.timestamp);
    }

    /**
        @dev    Function to complete the property Raise
        @dev    It emits a `CompleteRaise` event.
        @dev    Send funds to property owner exchange address and fees to
                platform multisig
        @param  id Property Id
    */
    function completeRaise(uint256 id) external onlyAdmin{

        require(!property[id].isCompleted, "Already Completed");

        property[id].isCompleted = true;

        /// @dev Send accumulated fees charged to investors
        uint256 tempPlatformFee = platformFee[id];
        IERC20(property[id].paymentToken).transfer(treasury, tempPlatformFee);
        platformFee[id] = 0;

        uint256 tempOwnersFee = ownersPlatformFee[id];
        IERC20(property[id].paymentToken).transfer(treasury,  tempOwnersFee);
        ownersPlatformFee[id] = 0;

        /// @dev Send property owners their share
        uint256 tempPropertyOwnerShare = propertyOwnerShare[id];
        IERC20(property[id].paymentToken).transfer(property[id].ownerExchAddr, tempPropertyOwnerShare);
        propertyOwnerShare[id] = 0;

        /// @dev fund the referralSystem Contract with property referrals share
        uint256 tempRefFee = refFee[id];
        IERC20(property[id].paymentToken).transfer(address(referralSystemCtr), tempRefFee);
        refFee[id] = 0;

        emit CompleteRaise(id);

    }

    /**
        @dev     Approves property to start raise
        @dev     It emits an `ApproveProperty` event.
        @param   id Property Id
        @param   raiseDeadline when the raise will end
    */
    function approveProperty(uint256 id, uint256 raiseDeadline) external onlyAdmin idMustBeValid(id){

        property[id].approved = true;
        property[id].raiseDeadline = raiseDeadline;

        emit ApproveProperty(id);
    }

    /**
        @dev     In case Hesty or property Manager gives up from raising funds for property
                 allow users to claim back their funds
        @dev     It emits a `CancelProperty` event
        @param   id Property Id
    */
    function cancelProperty(uint256 id) external onlyAdmin idMustBeValid(id){

        property[id].raiseDeadline = 0; // Important to allow investors to recover funds
        property[id].approved = false;  // Prevent more investments

        emit CancelProperty(id);
    }

    /**
        @dev     Function to change platform fee
        @dev     It emits a `NewPlatformFee` event.
        @dev     Fee must be lower than total amount raised
        @param   newFee New platform fee
    */
    function setPlatformFee(uint256 newFee) external onlyAdmin{

        require(newFee < BASIS_POINTS, "Fee must be valid");
        FEE_BASIS_POINTS = newFee;

        emit NewPlatformFee(newFee);
    }

    /**
        @dev     Function to change owners fee
        @dev     It emits a `NewOwnersFee` event.
        @dev     Fee must be lower than total amount raised
        @param   newFee New owners fee
    */
    function setOwnersFee(uint256 id, uint256 newFee) external onlyAdmin{

        require( newFee < BASIS_POINTS, "Fee must be valid");
        OWNERS_FEE_BASIS_POINTS[id] = newFee;

        emit NewOwnersFee(id, newFee);
    }

    /**
        @dev   Function to change referral fee
        @dev   Fee must be lower than fee charged by platform
        @param newFee New referral fee
    */
    function setRefFee(uint256 newFee) external onlyAdmin{
        require( newFee < FEE_BASIS_POINTS, "Fee must be valid");
        REF_FEE_BASIS_POINTS = newFee;
    }

    /**
        @dev    Function to change owners address where he will receive funds
        @dev    It emits a `NewPropertyOwnerAddrReceiver` event.
        @dev    Fee must be lower than fee charged by platform
        @param  id Property Id
        @param  newAddress New Property Owner Address
    */
    function setNewPropertyOwnerReceiverAddress(uint256 id, address newAddress) external onlyAdmin idMustBeValid(id){

        require( newAddress != address(0), "Address must be valid");
        property[id].ownerExchAddr = newAddress;

        emit NewPropertyOwnerAddrReceiver(newAddress);
    }

    /**
        @dev    Function to extend property raise deadline
        @param  id Property id
        @param  newDeadline The deadline for the raise
    */
    function extendRaiseForProperty(uint256 id, uint256 newDeadline) external onlyAdmin idMustBeValid(id){

        require(property[id].raiseDeadline < newDeadline, "Invalid deadline");
        property[id].raiseDeadline = newDeadline;
    }

    /**
        @dev    Function to set minimum investment amount
        @param  newMinInv Minimum Investment Amount
    */
    function setMinInvAmount(uint256 newMinInv) external onlyAdmin{
        require(newMinInv > 0, "Amount too low");
        minInvAmount = newMinInv;
    }

    /**
        @dev    Function to set the maximum number of referrals a user can have
        @param  newMax Maximum number of referrals
    */
    function setMaxNumberOfReferrals(uint256 newMax) external onlyAdmin{
        maxNumberOfReferrals = newMax;
    }

    /**
        @dev    Function to set the maximum amount of referral revenue
        @param  newMax Maximum amount of revenue
    */
    function setMaxAmountOfRefRev(uint256 newMax) external onlyAdmin{
        maxAmountOfRefRev = newMax;
    }

    /**
        @dev    Function to set a new treasury address
        @dev    It emits a `NewTreasury` event.
        @param  newTreasury The new treasury address
    */
    function setTreasury(address newTreasury) external onlyAdmin{

        require(newTreasury != address(0), "Not allowed");
        treasury = newTreasury;

        emit NewTreasury(newTreasury);
    }

    /**
        @dev    Function to set a new Referral Management Contract
        @dev    It emits a `NewReferralSystemCtr` event.
        @param  newReferralContract The new Referral Management Contract

    */
    function setReferralContract(address newReferralContract) external onlyAdmin{

        require(newReferralContract != address(0), "Not allowed");
        referralSystemCtr = IReferral(newReferralContract);

        emit NewReferralSystemCtr(newReferralContract);
    }

}