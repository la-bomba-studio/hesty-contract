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
*
*   @title Token Factory
*
*   @notice
*
*   @author Pedro G. S. Ferreira
*
    .##.....##.########.########.#########.##....##.
    .##.....##.##.......##..........##......##..##.
    .##.....##.##.........##........##........##.
    .#########.########.....##......##........##.
    .##.....##.##..........##.......##........##.
    .##.....##.##.........##........##........##.
    .##.....##.########.########....##........##.
*
*/

contract TokenFactory is
ReentrancyGuard,
Constants {

    IHestyAccessControl public ctrHestyControl;     // Hesty Access Control Contract
    IReferral           public referralSystemCtr;   // Referral System Contract

    uint256 public propertyCounter;         // Number of properties created until now
    uint256 public minInvAmount;            // Minimum amount allowed to invest
    uint256 public maxNumberOfReferrals;    // Maximum Number of Referrals that a user can have
    uint256 public maxAmountOfRefRev;       // Maximum Amount of Revenue a Referral can earn
    uint256 public FEE_BASIS_POINTS;        // Investment Fee charged by Hesty (in Basis Points)
    uint256 public OWNERS_FEE_BASIS_POINTS; // Owners Fee charged by Hesty (in Basis Points)
    uint256 public REF_FEE_BASIS_POINTS;    // Referral Fee charged by referrals (in Basis Points)

    address public treasury; // Address that will receive Hesty fees revenue

    bool    public initialized; // Checks if the contract is already initialized

    mapping(uint256 => PropertyInfo)    public property;            // Stores properties info
    mapping(uint256 => uint256)         public platformFee;         // (Property id => fee amount) The fee charged by the platform on every investment
    mapping(uint256 => uint256)         public ownersPlatformFee;   // The fee charged by the platform on every investment
    mapping(uint256 => uint256)         public propertyOwnerShare;  // The amount reserved to propertyOwner
    mapping(uint256 => uint256)         public refFee;              // The referral fee acummulated by each property before completing


    mapping(address => mapping(uint256 => uint256)) public userInvested; // Amount invested by each user in each property

    //Event
    event              InitializeFactory(address referralCtr);
    event                 CreateProperty(uint256 id);
    event        NewMaxNumberOfReferrals(uint256 number);
    event           NewMaxAmountOfRefRev(uint256 number);
    event           NewReferralSystemCtr(address newSystemCtr);
    event                    NewTreasury(address newTreasury);
    event          NewMinInvestmentLimit(uint256 newLimit);
    event   NewPropertyOwnerAddrReceiver(address newAddress);
    event                  NewInvestment(uint256 indexed propertyId, address investor, uint256 amount, uint256 date);
    event                 RevenuePayment(uint256 indexed propertyId, uint256 amount);
    event                 CancelProperty(uint256 propertyId);
    event                 NewPlatformFee(uint256 newFee);
    event                   NewOwnersFee(uint256 newFee);
    event                   ClaimProfits(address user, uint256 propertyId);
    event                  CompleteRaise(uint256 propertyId);
    event                   RecoverFunds(address indexed user, uint256 propertyId);
    event                ApproveProperty(uint256 propertyId);


    struct PropertyInfo{
        uint256 price;          // Price for each property token
        uint256 threshold;      // Amount necessary to proceed with investment
        uint256 raised;         // Amount raised until now
        uint256 raiseDeadline;  // When the fundraising ends
        uint8   payType;        // Type of investment return
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
        @param  ownersFee Owner Fee charged by Hesty (in Basis Points)
        @param  refFee_ Referaal Fee charged by referrals (in Basis Points)
        @param  treasury_ The Multi-Signature Address that will receive Hesty fees revenue
        @param  minInvAmount_ Minimum amount a user can invest
        @param  ctrHestyControl_ Contract that manages access to certain functions
    */
    constructor(
        uint256 fee,
        uint256 ownersFee,
        uint256 refFee_,
        address treasury_,
        uint256 minInvAmount_,
        address ctrHestyControl_
    ){

        require(refFee_ < fee, "Ref fee invalid");
        require(fee < BASIS_POINTS, "Invalid Platform Fee");
        require(ownersFee < BASIS_POINTS, "Invalid Fee");

        FEE_BASIS_POINTS        = fee;
        OWNERS_FEE_BASIS_POINTS = ownersFee;
        REF_FEE_BASIS_POINTS    = refFee_;
        minInvAmount            = minInvAmount_;
        treasury                = treasury_;
        maxNumberOfReferrals    = 20;               // Start with max 20 referrrals
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
        @notice Issue a new property token

        @param amount The amount of tokens to issue
        @param tokenPrice Token Price
        @param threshold Amount to reach in order to proceed to production
        @param payType Type of dividends payment
        @param paymentToken Token that will be charged on every investment made
    */
    function createProperty(
        uint256 amount,
        uint tokenPrice,
        uint256 threshold,
        uint8 payType,
        address paymentToken,
        address revenueToken,
        string memory name,
        string memory symbol,
        address admin
    ) external whenKYCApproved(msg.sender) whenNotAllPaused whenNotBlackListed returns(uint256) {

        require(paymentToken != address(0) && revenueToken != address(0), "Invalid pay token");

        address newAsset = address(new PropertyToken(address(this),
                                                            amount,
                                                            name,
                                                            symbol,
                                                            revenueToken,
                                                            admin));

        property[propertyCounter++] = PropertyInfo( tokenPrice,
                                                    threshold,
                                                    0,
                                                    0,
                                                    payType,
                                                    false,
                                                    false,
                                                    msg.sender,
                                                    msg.sender,
                                                    paymentToken,
                                                    newAsset,
                                                    revenueToken);


        emit CreateProperty(propertyCounter - 1);
        return propertyCounter - 1;
    }


    /**
        @dev    Function to buy property tokens
        @dev    If there is a referral store the fee to pay and transfer funds to this contract
        @param  id Property id
        @param  amount Amount of tokens that user wants to buy
        @param  ref The referral of the user, address(0) if doesn't exist
    */
    function buyTokens(address onBehalfOf, uint256 id, uint256 amount, address ref) external nonReentrant onlyWhenInitialized whenNotAllPaused {

        PropertyInfo storage p = property[id];

        // Require that raise is still active and not expired
        require(p.raiseDeadline >= block.timestamp, "Raise expired");
        require(amount >= minInvAmount, "Lower than min");
        require(property[id].approved, "Property Not For Sale");
        require(!property[id].isCompleted, "Property Sale Completed");

        // Calculate how much costs to buy tokens and
        // Calculate the investment fee and then
        // get the total investment cost
        uint256 boughtTokensPrice = amount * p.price;
        uint256 fee               = boughtTokensPrice * FEE_BASIS_POINTS / BASIS_POINTS;
        uint256 total             = boughtTokensPrice + fee;

        // Charge investment cost from user
        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        // Transfer Asset to buyer
        IERC20(p.asset).transfer(onBehalfOf, amount);

        //
        platformFee[id]              += fee;
        userInvested[msg.sender][id] += boughtTokensPrice;

        /// @dev Calculate owners fee
        uint256 ownersFee = boughtTokensPrice * OWNERS_FEE_BASIS_POINTS / BASIS_POINTS;

        ownersPlatformFee[id]  += ownersFee;
        propertyOwnerShare[id] += boughtTokensPrice - ownersFee;

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
                try referralSystemCtr.addRewards(onBehalfOf, ref, id, refFee_){
                    refFee[id] += refFee_;
                }catch{

                }
            }
        }
    }

    /*
        @dev    Distribution of revenue through property token holders
        @param  id Property id
        @param  amount The amount of funds in EURC to distribute
    */
    function distributeRevenue(uint256 id, uint256 amount) external nonReentrant whenNotAllPaused{

        require(id < propertyCounter, "Id must be valid");

        PropertyInfo storage p = property[id];

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
        IERC20(p.revenueToken).approve(p.asset, amount);
        PropertyToken(p.asset).distributionRewards(amount);

        emit RevenuePayment(id, amount);

    }

    /*
        @dev    Claim Investment returns
        @param  id Property id
    */
    function claimInvestmentReturns(uint256 id) external nonReentrant{

        PropertyInfo storage p = property[id];

        PropertyToken(p.asset).claimDividensExternal(msg.sender);

        emit ClaimProfits(msg.sender, id);
    }

    /*
        @dev    Claim Investment returns
        @param  id Property id
    */
    function recoverFundsInvested(uint256 id) external nonReentrant{

        PropertyInfo storage p = property[id];

        require(p.raiseDeadline < block.timestamp && !p.isCompleted, "Time not valid"); // @dev it must be < not <=

        uint256 amount               = userInvested[msg.sender][id];
        userInvested[msg.sender][id] = 0;

        IERC20(p.paymentToken).transfer(msg.sender, amount);

        emit RecoverFunds(msg.sender, id);

    }

    /*
        @dev    Buy Tokens without spending funds, this helpful for offchain investments
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


    /**=====================================
        Viewable Functions
    =========================================*/

    /**
        @dev    Checks if people can claim their referral share of a property
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

    /**
        @dev  Function to complete the property Raise
        @dev  Send funds to property owner exchange address and fees to
              platform multisig
    */
    function completeRaise(uint256 id) external onlyAdmin{

        require(!property[id].isCompleted, "Already Completed");

        property[id].isCompleted = true;

        /// @dev Send accumulated fees charged to investors
        platformFee[id] = 0;
        IERC20(property[id].paymentToken).transfer(treasury, platformFee[id]);

        ownersPlatformFee[id] = 0;
        IERC20(property[id].paymentToken).transfer(treasury,  ownersPlatformFee[id]);

        /// @dev Send property owners their share
        propertyOwnerShare[id] = 0;
        IERC20(property[id].paymentToken).transfer(property[id].ownerExchAddr, propertyOwnerShare[id]);


        /// @dev fund the referralSystem Contract with property referrals share
        refFee[id] = 0;
        IERC20(property[id].paymentToken).transfer(address(referralSystemCtr), refFee[id]);

        emit CompleteRaise(id);

    }

    /**
        @dev     Approves property to start raise
        @param   id Property Id
    */
    function approveProperty(uint256 id, uint256 raiseDeadline) external onlyAdmin idMustBeValid(id){

        property[id].approved = true;
        property[id].raiseDeadline = raiseDeadline;

        emit ApproveProperty(id);
    }

    /**
        @dev     In case Hesty or property Manager gives up from raising funds for property
                 allow users to claim back their funds
        @param   id Property Id
    */
    function cancelProperty(uint256 id) external onlyAdmin idMustBeValid(id){

        property[id].raiseDeadline = 0; // Important to allow investors to recover funds
        property[id].approved = false;  // Prevent more investements

        emit CancelProperty(id);
    }

    /**
        @dev     Function to change platform fee
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
    function setOwnersFee(uint256 newFee) external onlyAdmin{

        require( newFee < BASIS_POINTS, "Fee must be valid");
        OWNERS_FEE_BASIS_POINTS = newFee;

        emit NewOwnersFee(newFee);
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
        @dev    Function to change referral fee
        @dev    Fee must be lower than fee charged by platform
        @param  newAddress New Property Owner Address
    */
    function setNewPropertyOwnerReceiverAddress(uint256 id, address newAddress) external onlyAdmin idMustBeValid(id){

        require( newAddress != address(0), "Address must be valid");
        property[id].ownerExchAddr = newAddress;

        emit NewPropertyOwnerAddrReceiver(newAddress);
    }

    /**
    * @notice Function to extend property raise deadline
    *
    */
    function extendRaiseForProperty(uint256 id, uint256 newDeadline) external onlyAdmin idMustBeValid(id){

        require(property[id].raiseDeadline < newDeadline, "Invalid deadline");
        property[id].raiseDeadline = newDeadline;
    }

    /**
        @dev    Function to set minimum investment amount
        @dev    It emits a `NewMinInvestmentLimit` event.
        @param  newMinInv Minimum Investment Amount
    */
    function setMinInvAmount(uint256 newMinInv) external onlyAdmin{

        require(newMinInv > 0, "Amount too low");
        minInvAmount = newMinInv;

        emit NewMinInvestmentLimit(newMinInv);
    }

    /**
        @dev    Function to set the maximum number of referrals a user can have
        @dev    It emits a `NewMaxNumberOfReferrals` event.
        @param  newMax Maximum number of referrals
    */
    function setMaxNumberOfReferrals(uint256 newMax) external onlyAdmin{

        maxNumberOfReferrals = newMax;

        emit NewMaxNumberOfReferrals(newMax);
    }

    /**
        @dev    Function to set the maximum amount of referral revenue
        @dev    It emits a `NewMaxAmountOfRefRev` event.
        @param  newMax Maximum amount of revenue
    */
    function setMaxAmountOfRefRev(uint256 newMax) external onlyAdmin{

        maxAmountOfRefRev = newMax;

        emit NewMaxAmountOfRefRev(newMax);
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
