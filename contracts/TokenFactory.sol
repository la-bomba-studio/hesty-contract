pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Property, IERC20} from "./Property.sol";

contract TokenManager{

    uint256 public propertyCounter;

    mapping(uint256 => PropertyInfo) public property;
    mapping(string => PropertyInfo) public propertyinf;

    //Event
    event CreateProperty(uint256 id);

    struct PropertyInfo{
        string backendId;
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
        string memory bId,
        uint256 amount,
        uint tokenPrice,
        address paymentToken,
        address revenueToken,
        string memory name,
        string memory symbol
    ) external returns(uint256){
        address newAsset = address(new PropertyToken(address(this), amount, name, symbol));
        address newVault = address(new Property(IERC20(newAsset), revenueToken));
        property[propertyCounter++] = PropertyInfo(bId, tokenPrice, msg.sender, paymentToken, newAsset, newVault, revenueToken);
        propertyinf[bId] = PropertyInfo(bId, tokenPrice, msg.sender, paymentToken, newAsset, newVault, revenueToken);


    emit CreateProperty(propertyCounter - 1);
        return propertyCounter - 1;
    }

    function buyTokens(string memory id, uint256 amount) external payable{

        PropertyInfo storage p = propertyinf[id];

        uint256 boughtTokensPrice = amount * p.price;

        if(p.paymentToken != address(0)){
            IERC20(p.paymentToken).transferFrom(msg.sender, address(this), boughtTokensPrice);
        }else{
            require(msg.value >= boughtTokensPrice, "Invalid Amount");
        }

        IERC20(p.asset).transfer(msg.sender, amount * 1 ether);

        //Deposit Tokens in Vault
        //Property(p.vault).deposit(amount, msg.sender);

    }

    function distributeRevenue(string memory id, uint256 amount) public payable{

        PropertyInfo storage p = propertyinf[id];

        if(p.revenueToken != address(0)){
            IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);
            PropertyToken(p.asset).distributionRewards();
        }else{
            require(msg.value >= amount, "Revenue");
            PropertyToken(p.asset).distributionRewards{value: msg.value}();
        }



    }

    function withdrawAssets(string memory id) external{

        PropertyInfo storage p = propertyinf[id];

        PropertyToken(p.asset).claimDividensExternal(msg.sender);
    }

    // Function to allow deposits
    receive() external payable {}


}
