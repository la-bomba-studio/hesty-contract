// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPropertyToken {
    function getChildAddressBeforeDeployment(
        bytes memory _byteCode,
        uint256 _salt
    ) external view returns (address);

    function getBytecode(
        string memory _baseURI
    ) external pure returns (bytes memory);

    function getListOfPropertiesPerOwner(
        address _propertyOwner
    ) external view returns (address);

    function createChildProperty(
        address _propertyOwnerAddress,
        string calldata _baseURI,
        uint256 _salt
    ) external returns (address);
}
