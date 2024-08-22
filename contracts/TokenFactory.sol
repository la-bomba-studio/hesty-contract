pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Vault, IERC20} from "./Property.sol";

contract TokenFactory{

    uint256 public propertyCounter;

    mapping(uint256 => PropertyInfo) public property;

    //Event
    event CreateProperty(uint256 id);

    uint256 public FEE_BASIS_POINTS;
    uint256 public REF_FEE_BASIS_POINTS;

    uint256 public constant BASIS_POINTS = 10000;


    struct PropertyInfo{
        uint256 price;
        address owner;
        address paymentToken;
        address asset;
        address vault;
        address revenueToken;
    }

    mapping(address => uint256) lastTimeUserClaimed;

    constructor(uint256 fee, uint256 refFee){

        require(refFee < fee, "Ref fee invalid");
        FEE_BASIS_POINTS = fee;
        REF_FEE_BASIS_POINTS = refFee;

    }

    function createProperty(
        uint256 amount,
        uint tokenPrice,
        address paymentToken,
        address revenueToken,
        string memory name,
        string memory symbol
    ) external returns(uint256){
        require(paymentToken != address(0) && revenueToken != address(0), "Invalid pay token");


        address newAsset            = address(new PropertyToken(address(this), amount, name, symbol, revenueToken));
        address newVault            = address(new Vault(IERC20(newAsset), revenueToken));
        property[propertyCounter++] = PropertyInfo( tokenPrice, msg.sender, paymentToken, newAsset, newVault, revenueToken);


        emit CreateProperty(propertyCounter - 1);
        return propertyCounter - 1;
    }

    function buyTokens(uint256 id, uint256 amount, address ref) external payable{

        PropertyInfo storage p    = property[id];
        uint256 boughtTokensPrice = amount * p.price;

        uint256 fee = boughtTokensPrice * FEE_BASIS_POINTS / BASIS_POINTS;

        uint256 total = boughtTokensPrice + fee;

        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), total);

        IERC20(p.asset).transfer(msg.sender, amount);

        if(ref != address(0)){

            uint256 refFee = boughtTokensPrice * REF_FEE_BASIS_POINTS / BASIS_POINTS;
            IERC20(p.paymentToken).transfer(ref, REF_FEE_BASIS_POINTS);
        }

        //Deposit Tokens in Vault
        //Property(p.vault).deposit(amount, msg.sender);

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

    function setPlatformFee(uint256 newFee){
        require(FEE_BASIS_POINTS < BASIS_POINTS, "Fee must be valid");
        FEE_BASIS_POINTS = fee;
    }

    function setRefFee(uint256 newFee){
        require(REF_FEE_BASIS_POINTS < FEE_BASIS_POINTS, "Fee must be valid");
        REF_FEE_BASIS_POINTS = newFee;
    }

    function getPropertyToken(uint256 id) external view returns(address){
        return property[id].asset;
    }

    // Function to allow deposits
    receive() external payable {}


}
