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
contract ReferralSystem is ReentrancyGuard, IReferral {

     IHestyAccessControl public ctrHestyControl;                    // Hesty Global Access Control
     address             public rewardToken;                        // Token contract address of rewards
     ITokenFactory       public tokenFactory;                       // Token Factory Contract

     mapping(address => mapping(uint256 =>uint256)) public rewards; /// @notice Rewards earned by user indexed to each property
     mapping(address => uint256) public totalRewards;               /// @notice Total rewards earned by user indexed to properties
     mapping(address => uint256) public globalRewards;              /// @notice Total rewards earned by user not indexed to properties
     mapping(uint256 =>uint256)  public rewardsByProperty;          /// @notice Total rewards earned by users filtered by property
     mapping(address => uint256) public numberOfRef;                /// @notice Number of referrals a user has
     mapping(address => address) public referredBy;                 /// @notice Who reffered the user
     mapping(address => bool)    public approvedCtrs;               /// @notice Approved addresses that can add property rewards


    /**
        @dev    Referral System Constructor
        @param  rewardToken_ Token Reward (EURC)
        @param  ctrHestyControl_ Hesty Access Control Contract
        @param  tokenFactory_ Token Factory Contract
    */
    constructor(address rewardToken_, address ctrHestyControl_, address tokenFactory_) {

        rewardToken                 = rewardToken_;
        ctrHestyControl             = IHestyAccessControl(ctrHestyControl_);
        approvedCtrs[tokenFactory_] = true;
        tokenFactory                = ITokenFactory(tokenFactory_);

    }

    modifier whenNotAllPaused(){
        require(ctrHestyControl.paused(), "All Hesty Paused");
        _;
    }

    modifier whenKYCApproved(address user){
        require(ctrHestyControl.kycCompleted(user), "No KYC Made");
        _;
    }

    modifier whenNotBlackListed(address user){
        require(ctrHestyControl.blackList(user), "Blacklisted");
        _;
    }

    /**
        @dev Checks that `msg.sender` is an Admin
    */
    modifier onlyAdmin(){
        ctrHestyControl.onlyAdmin(msg.sender);
        _;
    }

    /**
        @dev    Add Rewards Associated to a Property Project
        @param  onBehalfOf User who referred and the one that will receive the income
        @param  user The user who were referenced by onBehalfOf user
        @param  projectId The Property project
        @param  amount The amount of rewards
    */
    function addRewards(address onBehalfOf, address user, uint256 projectId, uint256 amount) external whenNotAllPaused{

        require(approvedCtrs[msg.sender], "Not Approved");

        if(referredBy[user] == address(0)){
            referredBy[user]        = onBehalfOf;
            numberOfRef[onBehalfOf] += 1;
        }

        rewards[onBehalfOf][projectId] += amount;
        rewardsByProperty[projectId]   += amount;
        totalRewards[onBehalfOf]       += amount;

    }

    function addGlobalRewards(address onBehalfOf, address user, uint256 amount) external whenNotAllPaused{

        bool txVal = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(txVal, "Something odd happened");


        if(referredBy[user] == address(0)){
            referredBy[user]        = onBehalfOf;
            numberOfRef[onBehalfOf] += 1;
        }

        globalRewards[onBehalfOf] += amount;


    }

    function claimPropertyRewards(address user, uint256 projectId) external nonReentrant whenNotAllPaused whenKYCApproved(msg.sender) whenNotBlackListed(msg.sender){

        require(tokenFactory.isRefClaimable(projectId), "Not yet");

        uint256 rew   = rewards[user][projectId];
        rewards[user][projectId] = 0;

        IERC20(rewardToken).transfer(user, rew);

    }

    function claimGlobalRewards(address user) external nonReentrant whenNotAllPaused whenKYCApproved(msg.sender) whenNotBlackListed(msg.sender){


        uint256 rew   = globalRewards[user];
        globalRewards[user] = 0;

        IERC20(rewardToken).transfer(user, rew);

    }


    /**
        @dev Return Number of user referrals and user referral revenues
    */
    function getReferrerDetails(address user) external view returns(uint256, uint256, uint256){
        return(numberOfRef[user], totalRewards[user], globalRewards[user]);
   }

    function addApprovedCtrs(address newReferralRouter) external onlyAdmin{
        require(!approvedCtrs[newReferralRouter], "Already Approved");
        approvedCtrs[newReferralRouter] = true;
    }

    function removeApprovedCtrs(address oldReferralRouter) external onlyAdmin{
        require(approvedCtrs[oldReferralRouter], "Not Approved Router");
        approvedCtrs[oldReferralRouter] = false;
    }

    function setRewardToken(address newToken) external onlyAdmin{
        rewardToken = newToken;
    }

    function setHestyAccessControlCtr(address newControl) external onlyAdmin{
        require(newControl != address(0), "Not null");
        ctrHestyControl = IHestyAccessControl(newControl);
    }

    function setNewTokenFactory(address newfactory) external onlyAdmin{

        require(newfactory != address(0), "Not null");
        
        // Remove old approval and add new approval
        approvedCtrs[address(tokenFactory)] = false;
        approvedCtrs[newfactory] = true;

        tokenFactory = ITokenFactory(newfactory);
    }
}