// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title   Hesty Referral Interface
 * @author  Pedro G. S. Ferreira
 */
interface ITokenFactory {

    /// @notice Buy Tokens for users that acquired them off chain through EURO (FIAT)
    function adminBuyTokens(uint256 id, address buyer,  uint256 amount) external;

    /// @notice Distribute Revenue through
    function distributeRevenue(uint256 id, uint256 amount) external;

    /// @notice Return if it is already possible to claim referral revenue of a property
    function isRefClaimable(uint256 id) external view returns(bool);

    /// @notice Return property info the token asset address and the revenue address
    function getPropertyInfo(uint256 id) external view returns(address, address);

}
