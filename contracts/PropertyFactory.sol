// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./RealEstateToken.sol";
// import "contracts/libs/hardhat/console.sol";

contract PropertyFactory is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private index;

    address[] public RETTokens;

    constructor(){
        
    }

    event ChildCreated(uint256 indexed index, address childAddress);

    /**
        @notice this functions deploy new project token contract 
        @param _salt random salt 
        @param _admin Admin address for minter role
        @param _name name of property
    */
    function create(uint256 _salt, address _admin, string memory _name) external onlyOwner {
        RealEstateToken rettoken = (new RealEstateToken){salt: bytes32(_salt)}(_admin, _name);

        uint256 childIndex = index.current();
        index.increment();
        emit ChildCreated(childIndex, address(rettoken));

        RETTokens.push(address(rettoken));
    }

    /**
        @notice Returns the number of project token deployed
    */
    function allRETTokenLength() external view returns (uint256) {
        return RETTokens.length;
    }
}
