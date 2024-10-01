pragma solidity ^0.8.0;

interface IHestyAccessControl {

    function isUserKYCValid(address user) external returns(bool);

    function isAllPaused() external returns(bool);

    function isUserBlackListed(address user) external returns(bool);

}
