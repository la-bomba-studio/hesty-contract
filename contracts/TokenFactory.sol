pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Property, IERC20} from "./Property.sol";

contract TokenManager{

    uint256 public propertyCounter;

    mapping(uint256 => PropertyInfo) public property;

    //Event
    event CreateProperty(uint256 id);

    struct PropertyInfo{
        uint256 price;
        address owner;
        address paymentToken;
        address asset;
        address vault;
        address revenueToken;
    }

    mapping(address => uint256) lastTimeUserClaimed;

    constructor(){

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
        address newAsset = address(new PropertyToken(address(this), amount, name, symbol));
        address newVault = address(new Property(IERC20(newAsset), revenueToken));
        property[propertyCounter++] = PropertyInfo( tokenPrice, msg.sender, paymentToken, newAsset, newVault, revenueToken);


        emit CreateProperty(propertyCounter - 1);
        return propertyCounter - 1;
    }

    function buyTokens(uint256 id, uint256 amount) external payable{

        PropertyInfo storage p = property[id];

        uint256 boughtTokensPrice = amount * p.price;


        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), boughtTokensPrice);

        IERC20(p.asset).transfer(msg.sender, amount * 1 ether);

        //Deposit Tokens in Vault
        //Property(p.vault).deposit(amount, msg.sender);

    }

    function distributeRevenue(uint256 id, uint256 amount) public payable{

        PropertyInfo storage p = property[id];

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
        PropertyToken(p.asset).distributionRewards();


    }

    function withdrawAssets(uint256 id) external{

        PropertyInfo storage p = property[id];

        PropertyToken(p.asset).claimDividensExternal(msg.sender);
    }

    // Function to allow deposits
    receive() external payable {}


}
