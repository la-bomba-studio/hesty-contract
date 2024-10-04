// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenFactory {

    function distributeRevenue(uint256 id, uint256 amount) external;

    function isRefClaimable(uint256 id) external view returns(bool);

}
