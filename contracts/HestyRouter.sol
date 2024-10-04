// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "./interfaces/IHestyAccessControl.sol";
import "./interfaces/ITokenFactory.sol";
import "./Constants.sol";

/*
*
*   @title Hesty Router
*
*   @notice Receives funds from CEXs (example BisonBank)
*           and waits from distribution by Hesty
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
*
*/

contract HestyRouter is Constants, AccessControlDefaultAdminRules{

    ITokenFactory public tokenFactory;
    IHestyAccessControl public hestyAccessControl;

    modifier onlyAdmin(){
        IHestyAccessControl(hestyAccessControl).onlyAdmin(msg.sender);
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

    constructor(address tokenFactory_, address hestyAccessControl_) AccessControlDefaultAdminRules(
        3 days,
        msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){
        tokenFactory        = ITokenFactory(tokenFactory_);
        hestyAccessControl  = IHestyAccessControl(hestyAccessControl_);
    }

    /**
        @dev Distribute Rewards that were paid in EURO and converted to EURC
             through custodian
        @param propertyId The property Id
        @param amount Amount of funds to distribute
    */
    function adminDistribution(uint256 propertyId, uint256 amount) external onlyAdmin{
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

    function revertUserBuyTokens() external onlyAdmin{

    }

}
