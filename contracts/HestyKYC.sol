pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";
import "openzeppelin-solidity/contracts/utils/Pausable.sol";

/**
    @title Hesty KYC Control

    @notice Hesty Contract that is responsible to
            track the KYC made at Hesty

    @author
*/
contract HestyKYC is IHestyKYC, IAccessControlDefaultAdminRules, Pausable{

    bytes32 public constant PAUSER_ROLE      = keccak256("PAUSER_ROLE");        // @notice Role that can pause transfers
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");   // @notice Role than can blacklist addresses

    // 1 -> true 0/2 -> false
    mapping(address => bool)  public kycCompleted; // @notice Store user KYC status
    mapping(address => bool)  public blackList; // @notice Store user Blacklist status


    modifier onlyPauser(){
        require(hasRole(PAUSER_ROLE), "Not Pauser");
        _;
    }

    modifier onlyBlackLister(){
        require(hasRole(BLACKLISTER_ROLE), "Not Blacklister");
        _;
    }

    constructor() AccessControlDefaultAdminRules(
        3 days,
        msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

    }

    /**
        @notice Approve user KYC
        @dev Require this approval to allow users move Hesty derivatives
    */
    function approveUserKYC(address user) external onlyOwner{
        kycCompleted[user] = true;
    }

    /**
    * @notice Revert user KYC
    *
    *
    */
    function revertUserKYC() external onlyOwner{
        kycCompleted[user] = false;
    }

    function pause(address from, address to, uint256 amount) override external onlyPauser{
        super._pause();
    }

    function unpause(address from, address to, uint256 amount) override external onlyPauser{
        super._unpause();
    }

    /**

        @notice Returns KYC status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserKYCValid(address user) external returns(bool){
        return kycCompleted[user];
    }

    /**

        @notice Returns user blacklist status

        @return boolean that confirms if kyc is valid or not
    */
    function isUserBlackListed(address user) external returns(bool){
        return blackList[user];
    }
}
