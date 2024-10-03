pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/ITokenFactory.sol";
import "./interfaces/IReferral.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
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
    .##.....##.########.########....##........##:

*/

contract TokenFactory is ReentrancyGuard, AccessControlDefaultAdminRules, IReferral, ITokenFactory, Constants {

    uint256 public propertyCounter;  // @notice Number of properties created until now
    uint256 public minInvAmount;

    mapping(uint256 => PropertyInfo) public property; // @notice
    mapping(uint256 => uint256) public platformFee;   // @notice
    mapping(address => mapping(uint256 => uint256)) public refFee;        // @notice Referral Fee accumulated by users
    mapping(address => mapping(uint256 => uint256)) public userInvested; // @notice Amount invested by each user in each property
    //Event
    event CreateProperty(uint256 id);

    uint256 public FEE_BASIS_POINTS;
    uint256 public REF_FEE_BASIS_POINTS;

    address public treasury;

    uint256 public maxNumberOfReferrals;

    uint256 public maxAmountOfRefRev;

    IReferral public refCtr;

    struct PropertyInfo{
        uint256 price;          // Price for each property token
        uint256 threshold;      // Amount necessary to proceed with investment
        uint256 raised;         // Amount raised until now
        uint256 raiseDeadline;  // When the fundraising ends
        uint8   payType;        // Type of investment return
        bool    isCompleted;
        bool    approved;
        address owner;          // Property Manager/owner
        address ownerExchAddr;   // Property Owner/Manager exchange address to receive euroc
        address paymentToken;   // Token used to buy property tokens/assets
        address asset;          // Property token contract
       // address vault;
        address revenueToken;   // Revenue token for investors

    }

    mapping(address => uint256) lastTimeUserClaimed;

    modifier onlyAdmin(address manager){
        require(hasRole(DEFAULT_ADMIN_ROLE, manager), "Not Blacklist Manager");
        _;
    }

    modifier onlyBlackListManager(address manager){
        require(hasRole(BLACKLIST_MANAGER, manager), "Not Blacklist Manager");
        _;
    }

    modifier onlyKYCManager(address manager){
        require(hasRole(KYC_MANAGER, manager), "Not KYC Manager");
        _;
    }

    modifier onlyPauserManager(address manager){
        require(hasRole(PAUSER_MANAGER, manager), "Not Pauser Manager");
        _;
    }

    constructor(uint256 fee, uint256 refFee, address treasury_, uint256 minInvAmount_, address refCtr_) AccessControlDefaultAdminRules(
        3 days,
        msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

        require(refFee < fee, "Ref fee invalid");
        FEE_BASIS_POINTS        = fee;
        REF_FEE_BASIS_POINTS    = refFee;
        minInvAmount            = minInvAmount_;
        treasury                = treasury_;
        refCtr                  = IReferral(refCtr_);
        maxNumberOfReferrals    = 20;
        maxAmountOfRefRev       = 10000 * 1 ether;

    }

    /**===================================================
        NON OWNER STATE MODIFIABLE FUNTIONS
    ======================================================**/

    /**
    *  @notice Issue a new property token
    *
    *  @param amount The amount of tokens to issue
    *  @param tokenPrice Token Price
    *  @param threshold Amount to reach in order to proceed to production
    *  @param raiseEnd when the raise ends
    *  @param payType Type of dividends payment
    */
    function createProperty(
        uint256 amount,
        uint tokenPrice,
        uint256 threshold,
        uint256 raiseEnd,
        uint8 payType,
        address paymentToken,
        address revenueToken,
        string memory name,
        string memory symbol,
        address admin
    ) external returns(uint256){
        require(paymentToken != address(0) && revenueToken != address(0), "Invalid pay token");


        address newAsset            = address(new PropertyToken(address(this), amount, name, symbol, revenueToken, admin));
        property[propertyCounter++] = PropertyInfo( tokenPrice,
                                                    threshold,
                                                    0,
                                                    raiseEnd,
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
    * @notice Function to buy property tokens
    *
    * @dev If there is a referral store the fee to pay and transfer funds to this contract
    */
    function buyTokens(uint256 id, uint256 amount, address ref) external payable nonReentrant{

        PropertyInfo storage p    = property[id];

        // Require that raise is still active and not expired
        require(p.raiseDeadline >= block.timestamp, "Raise expired");
        require(amount > minInvAmount, "Lower than min");

        // Calculate how much costs to buy tokens
        uint256 boughtTokensPrice = amount * p.price;

        uint256 fee = boughtTokensPrice * FEE_BASIS_POINTS / BASIS_POINTS;

        uint256 total = boughtTokensPrice + fee;

        // Transfer payment from user
        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        IERC20(p.asset).transfer(msg.sender, amount);

        userInvested[msg.sender][id] += boughtTokensPrice;

        if(ref != address(0)){

            (uint256 userNumberRefs,uint256 userRevenue) = refCtr.getReferrerDetails(ref);

            if(userNumberRefs < 20 && userRevenue < 10000){

                uint256 refFee_ = boughtTokensPrice * REF_FEE_BASIS_POINTS / BASIS_POINTS;
                refFee[ref][id] += refFee_;

            }
        }

        p.raised += boughtTokensPrice;
        property[id] = p;
    }

    function distributeRevenue(uint256 id, uint256 amount) external nonReentrant{

        PropertyInfo storage p = property[id];

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
        IERC20(p.revenueToken).approve(p.asset, amount);
        PropertyToken(p.asset).distributionRewards(amount);


    }

    function withdrawAssets(uint256 id) external nonReentrant{

        PropertyInfo storage p = property[id];

        PropertyToken(p.asset).claimDividensExternal(msg.sender);
    }

    function recoverFundsInvested(uint256 id) external nonReentrant{

        PropertyInfo storage p = property[id];
        require(p.raiseDeadline < block.timestamp, "Time not valid"); // @dev it must be < not <=

        userInvested[msg.sender][id] = 0;
        IERC20(p.paymentToken).transfer(msg.sender, userInvested[msg.sender][id]);

    }

    /**
    *   @notice Distribute
    *
    *   @param id Property Id
    *   @param amount Amount of EURC to distribute through property token holders
    */
    function AdminDistributeRevenue(uint256 id, uint256 amount) external nonReentrant onlyAdmin(msg.sender){

        PropertyInfo storage p = property[id];
        IERC20(p.revenueToken).approve(p.asset, amount);
        PropertyToken(p.asset).distributionRewards(amount);

    }


    /**=====================================
        Viewable Functions
    =========================================*/


    function isRefClaimable(uint256 id) public view returns(bool){
        return property[id].threshold <= property[id].raised;
    }

    function getPropertyToken(uint256 id) external view returns(address){
        return property[id].asset;
    }

    /**
    * @notice Function to claim referral fee
    *
    * @param id the property id
    */
    function claimRefFee(uint256 id) external nonReentrant{
        uint256 val = refFee[msg.sender][id];
        require(isRefClaimable(id) && val > 0, "Not Claimable Yet");
        refFee[msg.sender][id] = 0;
        IERC20(property[id].paymentToken).transfer(msg.sender, val);
    }

    /**===================================================
       OWNER STATE MODIFIABLE FUNTIONS
   ======================================================**/

    /**
    * @notice Function to complete the property Raise
    *
    * @dev Send funds to property owner exchange address and fees to
            platform multisig
    */
    function completeRaise(uint256 id) external onlyAdmin(msg.sender){
        require(!property[id].isCompleted, "Already Completed");

        IERC20(property[id].paymentToken).transfer(property[id].ownerExchAddr, property[id].raised);

        IERC20(property[id].paymentToken).transfer(treasury, property[id].raised * FEE_BASIS_POINTS / BASIS_POINTS);
        property[id].isCompleted = true;
    }

    function approveProperty(uint256 id) external onlyAdmin(msg.sender){
        require(id < propertyCounter, "Fee must be valid");
        property[id].approved = true;
    }

    /**
    * @notice Function to change platform fee
    *
    * @dev Fee must be lower than total amount raised
    * @param newFee New platform fee
    */
    function setPlatformFee(uint256 newFee) external onlyAdmin(msg.sender){
        require(newFee < BASIS_POINTS, "Fee must be valid");
        FEE_BASIS_POINTS = newFee;
    }

    /**
    * @notice Function to change referral fee
    *
    * @dev Fee must be lower than fee charged by platform
    * @param newFee New referral fee
    */
    function setRefFee(uint256 newFee) external onlyAdmin(msg.sender){
        require( newFee < FEE_BASIS_POINTS, "Fee must be valid");
        REF_FEE_BASIS_POINTS = newFee;
    }

    /**
    * @notice Function to extend property raise deadline
    *
    */
    function extendRaiseForProperty(uint256 id, uint256 newDeadline) external onlyAdmin(msg.sender){
        require(property[id].raiseDeadline < newDeadline, "Invalid deadline");
        property[id].raiseDeadline = newDeadline;
    }

    /**
    * @notice Function to set minimum investment amount
    *
    */
    function setMinInvAmount(uint256 newMinInv) external onlyAdmin(msg.sender){
        minInvAmount = newMinInv;
    }

    function setMaxNumberOfReferrals(uint256 newMax) external{
        maxAmountOfRefRev = newMax;
    }

    // Function to allow deposits
    receive() external payable {}


}
