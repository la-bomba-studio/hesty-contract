// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title   Hesty Referral Interface
 *
 * @notice  Allows Hesty Contracts to access info about
            referrals and the referrals revenue amount
 *
 * @author  Pedro G. S. Ferreira
 */
interface IReferral {

    function getReferrerDetails(address user) external view returns(uint256, uint256);

    function addewards(address onBehalfOf, address referrer, uint256 amount) external;

}
