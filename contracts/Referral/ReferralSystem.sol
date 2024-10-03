// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IReferral.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IHestyAccessControl.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";

/*
* @notice This referral system is build a part
            from the
*/
contract ReferralSystem is IReferral, IHestyAccessControl {

     IHestyAccessControl public hestyAccessControl;

     mapping(address => uint256) public rewards; // @notice Total rewrds earned by user
     address public rewardToken;                 // @notice Token contract address of rewards
     mapping(address => mapping(address => bool)) public userRefs; // @notice Number of referrals a user has
     mapping(address => uint256) public numberOfRef; // @notice Number of referrals a user has

    modifier whenNotAllPaused(){
        require(IHestyAccessControl(hestyAccessControl).isAllPaused(), "All Hesty Paused");
        _;
    }

    constructor(address rewardToken_, address hestyAccessControl_) {
        rewardToken = rewardToken_;
        hestyAccessControl = IHestyAccessControl(hestyAccessControl_);

    }

    function deliverRewards(address onBehalfOf, address referrer,uint256 amount) external{

        bool tx = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(tx, "Something odd happened");


        if(!userRefs[referrer][onBehalfOf]){
            userRefs[referrer][onBehalfOf] = true;
        }

        rewards[onBehalfOf] += amount;

    }

    function claimRewards() external{


        uint256 rew         = rewards[msg.sender];
        rewards[msg.sender] = 0;

        IERC20(rewardToken).transfer(msg.sender, rew);

    }

    function getUserRevenueAmount(address user) public view returns(uint256){
        return rewards[user];
    }

    function getUserReferrals(address user) public view returns(uint256){
        return numberOfRef[user];
    }

    function getReferrerDetails(address user) external view returns(uint256, uint256){
        return(rewards[user], numberOfRef[user]);
    }

}
