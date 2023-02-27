// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/libs/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "contracts/libs/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "contracts/libs/@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "contracts/libs/@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";
import "contracts/libs/hardhat/console.sol";

contract PropertyFactory is
    ERC1155Upgradeable,
    ERC1155ReceiverUpgradeable,
    AccessControlUpgradeable,
    ERC1155URIStorageUpgradeable
{
    uint256 public _tokenCounter;
    bytes32 public constant PROPERTY_MANAGER = keccak256("PROPERTY_MANAGER");

    struct PropertyInfo {
        uint256 totalSupply;
        uint256 pricePerToken;
        uint256 thresholdTIme;
        bool isThresholdReached;
    }

    mapping(uint256 => PropertyInfo) public properties;

    function initialize() public initializer {
        __ERC1155_init("");
        __ERC1155URIStorage_init();
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PROPERTY_MANAGER, msg.sender);
        _tokenCounter = 0;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            ERC1155Upgradeable,
            ERC1155ReceiverUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId)
        public
        view
        virtual
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory)
    {
        return super.uri(tokenId);
    }

    function createProperty(
        uint256 _totalSupply,
        string memory _tokenUri,
        uint256 _pricePerToken
    ) external returns (uint256) {
        console.log("in create");
        require(
            hasRole(PROPERTY_MANAGER, msg.sender),
            "Must have minter role to create property"
        );

        // Mint tokens to escrow account
        uint256 tokenId = _tokenCounter;
        _tokenCounter += 1;
        _mint(address(this), tokenId, _totalSupply, "");
        // Set token URI
        _setURI(tokenId, _tokenUri);

        // Store threshold timestamp
        properties[tokenId] = PropertyInfo(
            _totalSupply,
            _pricePerToken,
            block.timestamp + 1 weeks,
            false
        );
        console.log("thres");

        return tokenId;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        require(
            hasRole(PROPERTY_MANAGER, operator) || to == address(this),
            "Cannot transfer tokens directly to buyer"
        );
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // handle incoming batch of tokens
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
}
