// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IHestyAccessControl.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/ITokenFactory.sol";
import "./Constants.sol";

/*
*
*   @title Hesty Router
*
*   @notice Receives funds from CEXs (example BisonBank or other)
*           and waits from distribution by Hesty
*
*   @author Pedro G. S. Ferreira

*/

contract HestyRouter is Constants, IRouter{

    ITokenFactory public tokenFactory;
    IHestyAccessControl public hestyAccessControl;
    IHestyAccessControl public pendingHestyAccessControl;

    event NewTokenFactory(address newFactory);
    event NewHestyAccessControl(address newAccessControl);
    event HestyAccessControlPending(address newAccessControl);

    /**
        @dev    Hesty Router Constructor
        @param  tokenFactory_ Token Factory Contract
        @param  hestyAccessControl_ Hesty Access Control Contract
    */
    constructor(address tokenFactory_, address hestyAccessControl_){
        tokenFactory        = ITokenFactory(tokenFactory_);
        hestyAccessControl  = IHestyAccessControl(hestyAccessControl_);
    }

    /**
        @dev Checks that `msg.sender` is an Admin
    */
    modifier onlyAdmin(){
        hestyAccessControl.onlyAdmin(msg.sender);
        _;
    }

    /**
        @dev Distribute Rewards that were paid in EURO and converted to EURC
             through custodian
        @param propertyId The property Id
        @param amount Amount of funds to distribute
    */
    function adminDistribution(uint256 propertyId, uint256 amount) external onlyAdmin{

        (,address tkn) = ITokenFactory(tokenFactory).getPropertyInfo(propertyId);

        IERC20(tkn).approve(address(tokenFactory), amount);

        ITokenFactory(tokenFactory).distributeRevenue(propertyId, amount);
    }

    /**
        @dev    Buy Tokens for users that paid in FIAT currency (EUR)
        @param  propertyId The property Id
        @param  onBehalfOf The user address of who bought with FIAT
        @param  amount Amount of funds to distribute
    */
    function offChainBuyTokens(uint256 propertyId, address onBehalfOf, uint256 amount) external onlyAdmin{
        ITokenFactory(tokenFactory).adminBuyTokens(propertyId, onBehalfOf, amount);
    }

    /**
        @dev    Set Hesty Access Control Contract
        @param  newControl Hesty Access Control Contract
    */
    function proposeNewAccessControl(address newControl) external onlyAdmin{

        require(newControl != address(0), "Not null");

        pendingHestyAccessControl = IHestyAccessControl(newControl);

        emit HestyAccessControlPending(newControl);

    }

    function confirmAccessControlChange() external override(IRouter){

        require(msg.sender == address(pendingHestyAccessControl),"Wrong Router");

        hestyAccessControl = pendingHestyAccessControl;

        delete pendingHestyAccessControl;

        emit NewHestyAccessControl(address(hestyAccessControl));
    }

    /**
        @dev    Set New Token Factory
        @param  newFactory New Token Factory
    */
    function setNewTokenFactory(address newFactory) external onlyAdmin{
        require(newFactory != address(0), "Not null");
        tokenFactory = ITokenFactory(newFactory);

        emit NewTokenFactory(newFactory);
    }

}
