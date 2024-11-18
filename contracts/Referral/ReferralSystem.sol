// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "../interfaces/IReferral.sol";
import "../interfaces/IHestyAccessControl.sol";
import "../interfaces/ITokenFactory.sol";

/*
    @title Hesty Referral System

    @notice This referral system that tracks, stores Hesty
            referral rewards and allows users to claim those
            rewards.

    @author Pedro G. S. Ferreira
*/
contract ReferralSystem is ReentrancyGuard, IReferral {

    IHestyAccessControl public ctrHestyControl;                     // Hesty Global Access Control
    address             public rewardToken;                         // Token Contract Address of rewards
    ITokenFactory       public tokenFactory;                        // Token Factory Contract

    mapping(address => mapping(uint256 =>uint256)) public rewards;  // Rewards earned by user indexed to each property

    mapping(address => uint256) public totalRewards;                // Total rewards earned by user indexed to properties
    mapping(address => uint256) public globalRewards;               // Total rewards earned by user not indexed to properties
    mapping(uint256 =>uint256)  public rewardsByProperty;           // Total rewards earned by users filtered by property
    mapping(address => uint256) public numberOfRef;                 // Number of referrals a user has
    mapping(address => address) public referredBy;                  // Who reffered the user
    mapping(address => bool)    public approvedCtrs;                // Approved addresses that can add property rewards


    event   AddPropertyRefRewards(uint256 indexed id, address onBehalfOf, uint256 amount);
    event        AddGlobalRewards(address indexed onBehalfOf, uint256 amount);
    event         NewTokenFactory(address newFactory);
    event   NewHestyAccessControl(address newAccessControl);
    event          NewRewardToken(address newRewardToken);
    event          NewApprovedCtr(address newReferralRouter);
    event      RemovedApprovedCtr(address router);
    event    ClaimPropertyRewards(uint256 indexed projectId, address user, uint256 rew);
    event      ClaimGlobalRewards(address indexed user, uint256 rew);


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

    /**
        @dev Checks that Hesty Contracts are not paused
    */
    modifier whenNotAllPaused(){
        require(!ctrHestyControl.paused(), "All Hesty Paused");
        _;
    }

    /**
        @dev Checks that `user` has kyc completed
    */
    modifier whenKYCApproved(address user){
        require(ctrHestyControl.kycCompleted(user), "No KYC Made");
        _;
    }

    /**
        @dev Checks that `user` is not blacklisted
    */
    modifier whenNotBlackListed(address user){
        require(!ctrHestyControl.blackList(user), "Blacklisted");
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
        @dev    It emits a `AddPropertyRefRewards` event
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

            rewards[onBehalfOf][projectId] += amount;
            rewardsByProperty[projectId]   += amount;
            totalRewards[onBehalfOf]       += amount;

            emit AddPropertyRefRewards(projectId, onBehalfOf, amount);

        }else if(referredBy[user] == onBehalfOf){

            rewards[onBehalfOf][projectId] += amount;
            rewardsByProperty[projectId]   += amount;
            totalRewards[onBehalfOf]       += amount;

            emit AddPropertyRefRewards(projectId, onBehalfOf, amount);
        }



    }

    /**
        @dev    Add Rewards Not Associated to a Property Project
        @dev    It emits a `AddGlobalRewards` event
        @param  onBehalfOf User who will receive rewards
        @param  amount The amount of rewards
    */
    function addGlobalRewards(address onBehalfOf, uint256 amount) external whenNotAllPaused{

        require(approvedCtrs[msg.sender], "Not Approved");

        bool txVal = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(txVal, "Something odd happened");

        globalRewards[onBehalfOf] += amount;

        emit AddGlobalRewards(onBehalfOf, amount);
    }

    /**
        @dev    Claim Property Rewards
        @dev    It emits a `ClaimPropertyRewards` event
        @param  user The user who earned referral revenue
        @param  projectId The Property Id
    */
    function claimPropertyRewards(address user, uint256 projectId) external nonReentrant whenNotAllPaused whenKYCApproved(msg.sender) whenNotBlackListed(msg.sender){

        require(tokenFactory.isRefClaimable(projectId), "Not yet");

        uint256 rew   = rewards[user][projectId];
        rewards[user][projectId] = 0;

        IERC20(rewardToken).transfer(user, rew);

        emit ClaimPropertyRewards(projectId, user, rew);
    }

    /**
        @dev    Claim Global Rewards
        @dev    It emits a `ClaimGlobalRewards` event
        @param  user The user who earned referral revenue
    */
    function claimGlobalRewards(address user) external nonReentrant whenNotAllPaused whenKYCApproved(msg.sender) whenNotBlackListed(msg.sender){

        uint256 rew   = globalRewards[user];
        globalRewards[user] = 0;

        IERC20(rewardToken).transfer(user, rew);

        emit ClaimGlobalRewards(user, rew);

    }

    /**
        @dev    Return Number of user referrals and user referral revenues
        @param  user The user who referred others
    */
    function getReferrerDetails(address user) external view returns(uint256, uint256, uint256){
        return(numberOfRef[user], totalRewards[user], globalRewards[user]);
   }

    /**
        @dev    Adds Contracts and Addresses that can add referral rewards
        @dev    It emits a `NewApprovedCtr` event
        @param  newReferralRouter Address that will add referral rewards
    */
    function addApprovedCtrs(address newReferralRouter) external onlyAdmin{
        require(!approvedCtrs[newReferralRouter], "Already Approved");
        approvedCtrs[newReferralRouter] = true;

        emit NewApprovedCtr(newReferralRouter);
    }

    /**
        @dev    Remove Approved Contract Routers
        @dev    It emits a `RemovedApprovedCtr` event
        @param  oldReferralRouter Address that added referral rewards
    */
    function removeApprovedCtrs(address oldReferralRouter) external onlyAdmin{
        require(approvedCtrs[oldReferralRouter], "Not Approved Router");
        approvedCtrs[oldReferralRouter] = false;

        emit RemovedApprovedCtr(oldReferralRouter);
    }

    /**
        @dev    Set New Reward Token
        @dev    It emits a `NewRewardToken` event
        @param  newToken The Reward Token Address
    */
    function setRewardToken(address newToken) external onlyAdmin{
        require(newToken != address(0), "Not null");
        rewardToken = newToken;

        emit NewRewardToken(newToken);
    }

    /**
        @dev    Set New Hesty Accces Control Contract
        @dev    It emits a `NewHestyAccessControl` event
        @param  newControl The New Hesty Access Control
    */
    function setHestyAccessControlCtr(address newControl) external onlyAdmin{
        require(newControl != address(0), "Not null");
        ctrHestyControl = IHestyAccessControl(newControl);

        emit NewHestyAccessControl(newControl);
    }

    /**
        @dev    Set New Hesty Factory Contract
        @dev    It emits a `NewTokenFactory` event
        @param  newFactory The New Hesty Factory
    */
    function setNewTokenFactory(address newFactory) external onlyAdmin{

        require(newFactory != address(0), "Not null");

        // Remove old approval and add new approval
        approvedCtrs[address(tokenFactory)] = false;
        approvedCtrs[newFactory] = true;

        tokenFactory = ITokenFactory(newFactory);

        emit NewTokenFactory(newFactory);
    }
}