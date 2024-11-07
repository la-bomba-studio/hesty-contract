// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
    @title   Hesty Access Control Interface
    @author  Pedro G. S. Ferreira
 */
interface IHestyAccessControl {

    /// @notice Require that only admins can call this function
    function onlyAdmin(address manager) external;

    /// @notice Require that only funds manager can call this function
    function onlyFundsManager(address manager) external;

    /// @notice Checks if an user is KYC approved in hesty
    function kycCompleted(address user) external returns(bool);

    /// @notice Checks if there is a global pause of Hesty Contracts
    function paused() external view returns(bool);

    /// @notice Checks if user is blacklisted from operating on Hesty or with
    ///         Hesty issued property tokens
    function blackList(address user) external returns(bool);

}
