// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
    @title   Hesty Referral Interface
    @author  Pedro G. S. Ferreira
 */
interface IIssuance {

    function createPropertyToken(
        uint256 amount,
        address revenueToken,
        string memory name,
        string memory symbol,
        address admin,
        address owner

    ) external returns(address);

}