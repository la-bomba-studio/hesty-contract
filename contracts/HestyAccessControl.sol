// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IHestyAccessControl.sol";
import "./Constants.sol";

/**
    @title Hesty Access Control

    @notice Hesty Contract that is responsible to
            make the control of all the contracts
            deployed by WorldHesty, Lda.

    @author Pedro G. S. Ferreira
*/
contract HestyAccessControl is IHestyAccessControl, AccessControlDefaultAdminRules, Pausable, Constants{


    mapping(address => bool)  public kycCompleted;  // @notice Store user KYC status
    mapping(address => bool)  public blackList;     // @notice Store user Blacklist status

    /**======================================

    MODIFIER FUNCTIONS

    =========================================**/

    modifier onlyAdminManager(address manager){
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

    /**======================================

    MUTABLE FUNCTIONS

    =========================================**/

    function onlyAdmin(address manager) onlyAdminManager(manager) external{}

    /**
        @notice Blacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function blacklistUser(address user) external onlyBlackListManager(msg.sender){
        blackList[user] = false;
    }

    /**
        @notice UnBlacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function unBlacklistUser(address user) external onlyBlackListManager(msg.sender){
        blackList[user] = false;
    }

    /**
        @notice Approve user KYC
                @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function approveUserKYC(address user) external onlyKYCManager(msg.sender){
        kycCompleted[user] = true;
    }

    /**
    * @notice Revert user KYC status
      @param user The Address of the user
    *
    *
    */
    function revertUserKYC(address user) external onlyKYCManager(msg.sender){
        kycCompleted[user] = false;
    }


    /**
        @notice Pause all Hesty Contracts
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function pause() external onlyPauserManager(msg.sender){
        super._pause();
    }

    /**
        @notice Unpause all Hesty Contracts
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function unpause() external onlyPauserManager(msg.sender){
        super._unpause();
    }

    /**======================================

    NON MUTABLE FUNCTIONS

    =========================================**/

    /**

        @notice Returns KYC status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserKYCValid(address user) external view returns(bool){
        return kycCompleted[user];
    }

    /**

        @notice Returns Paused Status

        @dev This pause affects all tokens and in the future all
             the logic of the marketplace

        @return boolean that confirms if kyc is valid or not
    */
    function isAllPaused() external view returns(bool){
        return super.paused();
    }

    /**

        @notice Returns user blacklist status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserBlackListed(address user) external view returns(bool){
        return blackList[user];
    }


}
