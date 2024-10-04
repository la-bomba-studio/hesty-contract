// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title   Hesty Referral Interface
 * @author  Pedro G. S. Ferreira
 */
interface ITokenFactory {

    /// @notice Distribute Revenue through
    function distributeRevenue(uint256 id, uint256 amount) external;

    function isRefClaimable(uint256 id) external view returns(bool);

}
