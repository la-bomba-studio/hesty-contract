pragma solidity ^0.8.0;

import {PropertyToken} from "./PropertyToken.sol";
import {Property, IERC20} from "./Property.sol";

contract TokenManager{

    uint256 propertyCounter;

    mapping(uint256 => PropertyInfo) property;

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
        address newAsset = address(new PropertyToken(address(this), amount, name, symbol));
        address newVault = address(new Property(IERC20(newAsset), IERC20(revenueToken)));
        property[propertyCounter++] = PropertyInfo(tokenPrice, msg.sender, paymentToken, newAsset, newVault, revenueToken);
        return propertyCounter - 1;
    }

    function buyTokens(uint256 id, uint256 amount) external{

        PropertyInfo storage p = property[id];

        uint256 boughtTokensPrice = amount * p.price;

        IERC20(p.paymentToken).transferFrom(msg.sender, address(this), boughtTokensPrice);

        //Deposit Tokens in Vault
        Property(p.vault).deposit(amount, msg.sender);

    }

    function distributeRevenue(uint256 id, uint256 amount) external{

        PropertyInfo storage p = property[id];

        IERC20(p.revenueToken).transferFrom(msg.sender, address(this), amount);

        Property(p.vault).distributeRewards(amount);

    }

}
