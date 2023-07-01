// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPropertyToken {
    function totalSupply(uint256 id) external view returns (uint256);

    function exists(uint256 id) external view returns (bool);

    function uri(uint256 id) external view returns (string memory);

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function balanceOfBatch(
        address[] memory account,
        uint256[] memory id
    ) external view returns (uint256);

    function checkIsManager(
        uint256 _propertyId,
        address _userAddress
    ) external returns (bool);

    function mintPropertyToken(
        address _reciever,
        uint256 _amount,
        string calldata _uri
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
