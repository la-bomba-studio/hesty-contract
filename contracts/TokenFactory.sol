pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Vault, IERC20} from "./Property.sol";

contract TokenFactory{

    uint256 public constant BASIS_POINTS = 10000;

    uint256 public propertyCounter;  // @notice Number of properties created until now

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

    constructor(uint256 fee, uint256 refFee, address treasury_){

        require(refFee < fee, "Ref fee invalid");
        FEE_BASIS_POINTS        = fee;
        REF_FEE_BASIS_POINTS    = refFee;
        treasury                = treasury_;


    }

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

    function buyTokens(uint256 id, uint256 amount, address ref) external payable{

        PropertyInfo storage p    = property[id];

        // Require that raise is still active and not expired
        require(p.raiseDeadline >= block.timestamp, "Raise expired");

        // Calculate how much costs to buy tokens
        uint256 boughtTokensPrice = amount * p.price;

        uint256 fee = boughtTokensPrice * FEE_BASIS_POINTS / BASIS_POINTS;

        uint256 total = boughtTokensPrice + fee;

        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        IERC20(p.asset).transfer(msg.sender, amount);

        userInvested[msg.sender][id] += total;

       // if(ref != address(0)){

         //   uint256 refFee = boughtTokensPrice * REF_FEE_BASIS_POINTS / BASIS_POINTS;
         //   IERC20(p.paymentToken).transfer(ref, REF_FEE_BASIS_POINTS);
       // }


        //Deposit Tokens in Vault
        //Property(p.vault).deposit(amount, msg.sender);

        p.raised += boughtTokensPrice;
        property[id] = p;
    }

    function distributeRevenue(uint256 id, uint256 amount) public{

        PropertyInfo storage p = property[id];

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
        IERC20(p.revenueToken).approve(p.asset, amount);
        PropertyToken(p.asset).distributionRewards(amount);


    }

    function withdrawAssets(uint256 id) external{

        PropertyInfo storage p = property[id];

        PropertyToken(p.asset).claimDividensExternal(msg.sender);
    }

    function recoverFundsInvested(uint256 propertyId) external{

        PropertyInfo storage p = property[id];
        require(p.raiseDeadline < block.timestamp, "Time not valid"); // @dev it must be < not <=


    }

    function completeRaise() external{
        require(!property[id], "Already Completed");

        IERC20(property[id].paymentToken).transfer(property[id].ownerExchAddr, property[id].raised);

        IERC20(property[id].paymentToken).transfer(treasury, property[id].raised * FEE_BASIS_POINTS / BASIS_POINTS);
        property[id].isCompleted = true;
    }

    function isRefClaimable(uint256 propertyId) public view returns(bool){
        return property[id].threshold <= property[id].raised;
    }

    function claimRefFee() external{
        require(isRefClaimable(), "Not Claimable Yet");

    }

    function setPlatformFee(uint256 newFee) external{
        require(newFee < BASIS_POINTS, "Fee must be valid");
        FEE_BASIS_POINTS = newFee;
    }

    function setRefFee(uint256 newFee) external{
        require( newFee < FEE_BASIS_POINTS, "Fee must be valid");
        REF_FEE_BASIS_POINTS = newFee;
    }

    function getPropertyToken(uint256 id) external view returns(address){
        return property[id].asset;
    }

    function extendRaiseForProperty(uint256 id, uint256 newDeadline) external{
        require(property[id].raiseDeadline < newDeadline, "Invalid deadline");
        property[id].raiseDeadline = newDeadline;
    }

    // Function to allow deposits
    receive() external payable {}


}
