// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title   Hesty Access Control Interface
 * @notice  Allows Hesty Contracts to access info about global
 *          pauses, locks and user kyc status.
 *
 * @author  Pedro G. S. Ferreira
 */
interface IHestyAccessControl {

    /// @notice Checks if an user has kyc approved in hesty
    function isUserKYCValid(address user) external returns(bool);

    /// @notice Checks if there is a global pause
    function isAllPaused() external returns(bool);

    /// @notice Checks if user is blacklisted from operating on Hesty or with
    ///            Hesty issued property tokens
    function isUserBlackListed(address user) external returns(bool);

}
