pragma solidity ^0.8.0;

/**
 * @title Constant values shared across Hesty smart contracts.
 */
abstract contract Constants {

    /// @notice Math Helper to get percentages amounts
    uint256 public constant BASIS_POINTS = 100_00;

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
