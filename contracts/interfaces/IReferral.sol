// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
    @title   Hesty Referral Interface
    @author  Pedro G. S. Ferreira
 */
interface IReferral {

    /// @notice Returns user referral numbers and revenue
    function getReferrerDetails(address user) external view returns(uint256, uint256, uint256);

    /// @notice Adds Property Referral Rewards to the user
    function addRewards(address onBehalfOf, address ref, uint256 boughtTokensPrice, uint256 id) external ;

    /// @notice Adds referral rewards to the user (not indexed to a property)
    function addGlobalRewards(address onBehalfOf, uint256 amount) external;

    /// @notice Claim User Property Referral rewards
    function claimPropertyRewards(address user, uint256 projectId) external;

    /// @notice Claim User Global Referral rewards
    function claimGlobalRewards(address user) external;
}
