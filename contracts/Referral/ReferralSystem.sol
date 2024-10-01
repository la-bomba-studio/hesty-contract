pragma solidity ^0.8.0;

import "../interfaces/IReferral.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
* @notice This referral system is build a part
            from the
*/
contract ReferralSystem is IReferral {

     mapping(address => uint256) public rewards; // @notice Rewards to be payed to User
     address public rewardToken;                 // @notice Token contract address of rewards

    constructor(address rewardToken_){
        rewardToken = rewardToken_;
    }

    function deliverRewards(address onBehalfOf, uint256 amount) external{

        bool tx = IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        require(tx, "Something odd happened");

        rewards[onBehalfOf] += amount;

    }

    function claimRewards() external{


        uint256 rew         = rewards[msg.sender];
        rewards[msg.sender] = 0;

        IERC20(rewardToken).transfer(msg.sender, rew);

    }

}
