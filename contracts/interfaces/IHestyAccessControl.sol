// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title   Hesty Access Control Interface
 * @author  Pedro G. S. Ferreira
 */
interface IHestyAccessControl {

    /// @notice Require that only admins call this function
    function onlyAdmin(address manager) external;

    /// @notice Checks if an user has kyc approved in hesty
    function kycCompleted(address user) external returns(bool);

    /// @notice Checks if there is a global pause
    function paused() external view returns(bool);

    /// @notice Checks if user is blacklisted from operating on Hesty or with
    ///         Hesty issued property tokens
    function blackList(address user) external returns(bool);

}
