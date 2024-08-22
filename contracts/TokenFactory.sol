pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Vault, IERC20} from "./Property.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenFactory is Ownable2Step, ReentrancyGuard{

    uint256 public constant BASIS_POINTS = 10000;

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

    struct PropertyInfo{
        uint256 price;          // Price for each property token
        uint256 threshold;      // Amount necessary to proceed with investment
        uint256 raised;         // Amount raised until now
        uint256 raiseDeadline;  // When the fundraising ends
        uint8   payType;        // Type of investment return
        bool    isCompleted;
        address owner;          // Property Manager/owner
        address ownerExchAddr;   // Property Owner/Manager exchange address to receive euroc
        address paymentToken;   // Token used to buy property tokens/assets
        address asset;          // Property token contract
       // address vault;
        address revenueToken;   // Revenue token for investors

    }

    mapping(address => uint256) lastTimeUserClaimed;

    constructor(uint256 fee, uint256 refFee, address treasury_, uint256 minInvAmount_){

        require(refFee < fee, "Ref fee invalid");
        FEE_BASIS_POINTS        = fee;
        REF_FEE_BASIS_POINTS    = refFee;
        minInvAmount            = minInvAmount_;
        treasury                = treasury_;


    }

    /**===================================================
        NON OWNER STATE MODIFIABLE FUNTIONS
    ======================================================**/

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
        //address newVault            = address(new Vault(IERC20(newAsset), revenueToken));
        property[propertyCounter++] = PropertyInfo( tokenPrice,
                                                    threshold,
                                                    0,
                                                    raiseEnd,
                                                    payType,
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

        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        IERC20(p.asset).transfer(msg.sender, amount);

        userInvested[msg.sender][id] += boughtTokensPrice;

        if(ref != address(0)){
            uint256 refFee_ = boughtTokensPrice * REF_FEE_BASIS_POINTS / BASIS_POINTS;
            refFee[ref][id] += refFee_;
        }

        p.raised += boughtTokensPrice;
        property[id] = p;
    }

    function distributeRevenue(uint256 id, uint256 amount) public nonReentrant{

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
    function completeRaise(uint256 id) external onlyOwner{
        require(!property[id].isCompleted, "Already Completed");

        IERC20(property[id].paymentToken).transfer(property[id].ownerExchAddr, property[id].raised);

        IERC20(property[id].paymentToken).transfer(treasury, property[id].raised * FEE_BASIS_POINTS / BASIS_POINTS);
        property[id].isCompleted = true;
    }

    /**
    * @notice Function to change platform fee
    *
    * @dev Fee must be lower than total amount raised
    * @param newFee New platform fee
    */
    function setPlatformFee(uint256 newFee) external onlyOwner{
        require(newFee < BASIS_POINTS, "Fee must be valid");
        FEE_BASIS_POINTS = newFee;
    }

    /**
    * @notice Function to change referral fee
    *
    * @dev Fee must be lower than fee charged by platform
    * @param newFee New referral fee
    */
    function setRefFee(uint256 newFee) external onlyOwner{
        require( newFee < FEE_BASIS_POINTS, "Fee must be valid");
        REF_FEE_BASIS_POINTS = newFee;
    }

    /**
    * @notice Function to extend property raise deadline
    *
    */
    function extendRaiseForProperty(uint256 id, uint256 newDeadline) external onlyOwner{
        require(property[id].raiseDeadline < newDeadline, "Invalid deadline");
        property[id].raiseDeadline = newDeadline;
    }

    /**
    * @notice Function to set minimum investment amount
    *
    */
    function setMinInvAmount(uint256 newMinInv) external onlyOwner{
        minInvAmount = newMinInv;
    }

    // Function to allow deposits
    receive() external payable {}


}
