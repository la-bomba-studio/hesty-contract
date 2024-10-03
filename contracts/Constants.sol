pragma solidity ^0.8.0;

/**
 * @title Constant values shared across mixins.
 */
abstract contract Constants {

    uint256 public constant BASIS_POINTS = 100_00;

    bytes32 public constant BLACKLIST_MANAGER   = keccak256("BLACKLIST_MANAGER");     // @notice Role than can blacklist addresses

    bytes32 public constant KYC_MANAGER         = keccak256("KYC_MANAGER");           // @notice Role that can pause transfers

    bytes32 public constant PAUSER_MANAGER      = keccak256("PAUSER_MANAGER");        // @notice Role that can pause transfers

}
