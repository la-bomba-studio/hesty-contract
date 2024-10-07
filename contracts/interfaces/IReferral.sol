// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title   Hesty Referral Interface
    @author  Pedro G. S. Ferreira
 */
interface IReferral {

    /// @notice Returns user referral numbers and revenue
    function getReferrerDetails(address user) external view returns(uint256, uint256, uint256);

    /// @notice Adds referral rewards to the user claim indexed to a property
    function addRewards(address onBehalfOf, address referrer, uint256 projectId, uint256 amount) external;

    /// @notice Adds referral rewards to the user claim not indexed to a property
    function addGlobalRewards(address onBehalfOf, uint256 amount) external;

    /// @notice Claim User Property Referral rewards
    function claimPropertyRewards(address user, uint256 projectId) external;

    /// @notice Claim User General Referral rewards (to be implemented in the future)
    function claimGlobalRewards(address user) external;
}
