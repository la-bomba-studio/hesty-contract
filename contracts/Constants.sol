// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Constant values shared across Hesty smart contracts.
 */
abstract contract Constants {

    /// @notice Math Helper to get percentages amounts
    uint256 internal constant BASIS_POINTS = 100_00;

    uint256 internal constant MAX_FEE_POINTS = 30_00;

    uint256 internal constant EXTENDED_TIME = 60 * 60 * 24 * 15;

    /// @notice Math Helper for getting EURC power of decimals
    uint256 internal constant WAD = 10 ** 6;

    uint256 internal constant TEN_POWER_FIFTEEN = 10 ** 15;

    /// @notice Multiplier to guarantee math precision safety, is does not ensure 100% but
    ///             the rest is neglectable as EURC has only 6 decimals
    uint128 internal constant MULTIPLIER  = 1e32;

    /// @notice Role than can blacklist addresses
    /// @dev Secuirty Level: 3
    bytes32 public constant BLACKLIST_MANAGER   = keccak256("BLACKLIST_MANAGER");

    /// @notice Role that synchoronizes offchain investment
    /// @dev Secuirty Level: 1
    bytes32 public constant FUNDS_MANAGER       = keccak256("FUNDS_MANAGER");

    /// @notice Role that approves users KYC done
    /// @dev Secuirty Level: 3
    bytes32 public constant KYC_MANAGER         = keccak256("KYC_MANAGER");

    /// @notice Role that can pause transfers
    /// @dev Secuirty Level: 2
    bytes32 public constant PAUSER_MANAGER      = keccak256("PAUSER_MANAGER");



}
