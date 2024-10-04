// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IReferral.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IHestyAccessControl.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/ITokenFactory.sol";

/*
* @notice This referral system is build a part
            from the
*/
contract ReferralSystem is ReentrancyGuard, IReferral, IHestyAccessControl, ITokenFactory {

     IHestyAccessControl public ctrHestyControl;                    /// @notice Hesty Global Access Control
     address             public rewardToken;                        /// @notice Token contract address of rewards
     ITokenFactory       public tokenFactory;

     mapping(address => mapping(uint256 =>uint256)) public rewards; /// @notice Total rewards earned by user indexed to properties
     mapping(address => uint256) public globalRewards;              /// @notice Total rewards earned by user not indexed to properties
     mapping(uint256 =>uint256)  public rewardsByProperty;          /// @notice Total rewards earned by users filtered by property
     mapping(address => uint256) public numberOfRef;                /// @notice Number of referrals a user has
     mapping(address => address) public refferedBy;                 /// @notice Who reffered the user
     mapping(address => bool)    public approvedCtrs;               /// @notice Approved addresses that can add property rewards

    modifier whenNotAllPaused(){
        require(IHestyAccessControl(ctrHestyControl).isAllPaused(), "All Hesty Paused");
        _;
    }

    modifier whenKYCApproved(address user){
        require(IHestyAccessControl(ctrHestyControl).isUserKYCValid(user), "No KYC Made");
        _;
    }

    modifier whenNotBlackListed(address user){
        require(IHestyAccessControl(ctrHestyControl).isUserBlackListed(user), "Blacklisted");
        _;
    }


    constructor(address rewardToken_, address ctrHestyControl_, address tokenFactory_) {
        rewardToken = rewardToken_;
        ctrHestyControl = IHestyAccessControl(ctrHestyControl_);
        tokenFactory = tokenFactory_;
        approvedCtrs[tokenFactory] = true;

    }

    /**
    *   @notice Add Rewards Associated to a Property Project
    *   @param onBehalfOf User who referred and the one that will receive the income
    *   @param user The user who were referenced by onBehalfOf user
    *   @param projectId The Property project
    *   @param amount The amount of rewards
    */
    function addRewards(address onBehalfOf, address user, uint256 projectId, uint256 amount) external whenNotAllPaused{

        require(approvedCtrs[msg.sender], "Not Approved");

        bool tx = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(tx, "Something odd happened");


        if(refferedBy[user] == address(0)){
            refferedBy[user] = onBehalfOf;
            numberOfRef[onBehalfOf] += 1;
        }

        rewards[onBehalfOf][projectId] += amount;
        rewardsByProperty[projectId] += amount;


    }

    function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external whenNotAllPaused{

        bool tx = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(tx, "Something odd happened");


        if(refferedBy[user] == address(0)){
            refferedBy[user] = onBehalfOf;
            numberOfRef[onBehalfOf] += 1;
        }

        globalRewards[onBehalfOf] += amount;


    }

    function claimPropertyRewards(address user, uint256 projectId) external nonReentrant whenNotAllPaused whenKYCApproved whenNotBlackListed{

        require(tokenFactory.isRefClaimable(projectId), "Not yet");

        uint256 rew   = rewards[user][projectId];
        rewards[user][projectId] = 0;

        IERC20(rewardToken).transfer(user, rew);

    }

    function claimGlobalRewards(address user) external nonReentrant whenNotAllPaused whenKYCApproved whenNotBlackListed{


        uint256 rew   = globalRewards[user];
        globalRewards[user] = 0;

        IERC20(rewardToken).transfer(user, rew);

    }


    /**
    * @notice J
    */
    function getReferrerDetails(address user) external view returns(uint256, uint256, uint256){
        return(numberOfRef[user], rewards[user], globalRewards[user]);
   }

    function setRewardToken(address newToken) external{
        rewardToken = newToken;
    }
}