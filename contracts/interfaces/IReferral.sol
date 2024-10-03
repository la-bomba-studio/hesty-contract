// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReferral {

    function getUserReferrals(address user) external view returns(uint256);

    function getUserRevenueAmount(address user) external view returns(uint256);

    function getReferrerDetails(address user) external view returns(uint256, uint256);

    function deliverRewards(address onBehalfOf, address referrer, uint256 amount) external;


}
