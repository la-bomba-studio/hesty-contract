pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
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

    constructor() AccessControlDefaultAdminRules(
        3 days,
        msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

    }


    function distribute() external{


    }

    function offChainBuyTokens(){

    }

    function revertUserBuyTokens(){

    }

}
