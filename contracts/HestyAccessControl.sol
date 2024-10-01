pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/IAccessControlDefaultAdminRules.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IHestyAccessControl.sol";

/**
    @title Hesty Access Control

    @notice Hesty Contract that is responsible to
            track the KYC made at Hesty

    @author Pedro G. S. Ferreira
*/
contract HestyAccessControl is IHestyAccessControl, IAccessControlDefaultAdminRules, Pausable{

    bytes32 public constant BLACKLIST_MANAGER   = keccak256("BLACKLIST_MANAGER");   // @notice Role than can blacklist addresses
    bytes32 public constant KYC_MANAGER         = keccak256("PAUSER_MANAGER");        // @notice Role that can pause transfers
    bytes32 public constant PAUSER_MANAGER      = keccak256("PAUSER_MANAGER");        // @notice Role that can pause transfers

    // 1 -> true 0/2 -> false
    mapping(address => bool)  public kycCompleted;  // @notice Store user KYC status
    mapping(address => bool)  public blackList;     // @notice Store user Blacklist status

    /**======================================

    MODIFIER FUNCTIONS

    =========================================**/


    modifier onlyBlackListManager(){
        require(hasRole(BLACKLISTER_MANAGER), "Not Blacklister");
        _;
    }

    modifier onlyKYCManager(){
        require(hasRole(BLACKLISTER_MANAGER), "Not Blacklister");
        _;
    }

    modifier onlyPauserManager(){
        require(hasRole(PAUSER_MANAGER), "Not Pauser");
        _;
    }


    constructor() IAccessControlDefaultAdminRules(
        3 days,
        msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

    }

    /**======================================

    MUTABLE FUNCTIONS

    =========================================**/

    /**
        @notice Approve user KYC
                @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function approveUserKYC(address user) external onlyKYCManager{
        kycCompleted[user] = true;
    }

    /**
    * @notice Revert user KYC status
      @param user The Address of the user
    *
    *
    */
    function revertUserKYC(address user) external onlyKYCManager{
        kycCompleted[user] = false;
    }

    /**
        @notice Blacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function blacklistUser(address user) external onlyBlackListManager{
        blackList[user] = false;
    }

    /**
        @notice UnBlacklist user
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function unBlacklistUser(address user) external onlyBlackListManager{
        blackList[user] = false;
    }

    /**
        @notice Pause all Hesty Contracts
        @param user The Address of the user
        @dev Require this approval to allow users move Hesty derivatives
             onlyOnwer
    */
    function pause() external onlyPauserManager{
        super._pause();
    }

    function unpause() external onlyPauserManager{
        super._unpause();
    }

    /**======================================

    NON MUTABLE FUNCTIONS

    =========================================**/

    /**

        @notice Returns KYC status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserKYCValid(address user) external returns(bool){
        return kycCompleted[user];
    }

    /**

        @notice Returns Paused Status

        @dev This pause affects all tokens and in the future all
             the logic of the marketplace

        @return boolean that confirms if kyc is valid or not
    */
    function isAllPaused() external returns(bool){
        return super.paused();
    }

    /**

        @notice Returns user blacklist status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserBlackListed(address user) external returns(bool){
        return blackList[user];
    }


}
