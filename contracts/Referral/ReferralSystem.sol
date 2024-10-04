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

     IHestyAccessControl public hestyAccessControl;                 // @notice

     mapping(address => mapping(uint256 =>uint256)) public rewards; // @notice Total rewrds earned by user
     address public rewardToken;                                    // @notice Token contract address of rewards
     mapping(address => uint256) public numberOfRef;                // @notice Number of referrals a user has
     mapping(address => address) public refferedBy;                 // @notice Who reffered the user

    modifier whenNotAllPaused(){
        require(IHestyAccessControl(hestyAccessControl).isAllPaused(), "All Hesty Paused");
        _;
    }

    modifier whenKYCApproved(address user){
        require(IHestyAccessControl(ctrHestyControl).isUserKYCValid(user), "No KYC Made");
        _;
    }


    constructor(address rewardToken_, address hestyAccessControl_) {
        rewardToken = rewardToken_;
        hestyAccessControl = IHestyAccessControl(hestyAccessControl_);

    }

    /**
    *   @notice
    */
    function addRewards(address onBehalfOf, address user, uint256 project, uint256 amount) external whenNotAllPaused{

        bool tx = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(tx, "Something odd happened");


        if(refferedBy[user] == address(0)){
            refferedBy[user] = onBehalfOf;
            numberOfRef[onBehalfOf] += 1;
        }

        rewards[onBehalfOf][id] += amount;

    }

    function claimRewards(address user, uint256 projectId) external whenNotAllPaused whenKYCApproved{


        uint256 rew   = rewards[user][projectId];
        rewards[user] = 0;

        IERC20(rewardToken).transfer(user, rew);

    }


    /**
    * @notice J
    */
    function getReferrerDetails(address user) external view returns(uint256, uint256){
        return(rewards[user], numberOfRef[user]);
   }
}