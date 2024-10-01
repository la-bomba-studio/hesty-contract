pragma solidity ^0.8.0;

interface IHestyKYC {

    function isUserKYCValid(address user) external returns(bool);

    function isUserBlackListed(address user) external returns(bool);

}
