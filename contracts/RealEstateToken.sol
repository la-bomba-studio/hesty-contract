// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";

contract RealEstateToken is ERC1155Supply, AccessControl {
    using Counters for Counters.Counter;
    string public name;

    Counters.Counter private _tokenIds;

    bytes32 public constant PROPERTY_MANAGER = keccak256("PROPERTY_MANAGER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");


    event Mint(
        uint256 indexed tokenId,
        address reciever,
        uint256 amount,
        string uri
    );

    struct PropertyInfo {
        uint256 totalSupply;
        uint256 pricePerToken;
        uint256 thresholdTIme;
        bool isThresholdReached;
    }

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => PropertyInfo) public properties;


    constructor(address _admin, string memory _name) ERC1155("") {
        _setRoleAdmin(PROPERTY_MANAGER, ADMIN_ROLE);
        _setupRole(PROPERTY_MANAGER, _admin);
        name = _name;

    }

    /**
        @notice minting new project tokens
        @dev calls 1155 _mint funcntion after validating the parameters
        @param _pricePerToken price per token 
        @param _totalSupply number of copies
        @param _tokenUri MetaDataURI of the NFT
    */
    
    function createProperty(
        uint256 _totalSupply,
        string calldata _tokenUri,
        uint256 _pricePerToken
    ) external returns (uint256) {
        require(
            hasRole(PROPERTY_MANAGER, msg.sender),
            "Must have minter role to create property"
        );

        _beforeTokenMint(msg.sender, _totalSupply, _tokenUri);

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        
        // Set token URI
        _setURI(tokenId, _tokenUri);

        // Store threshold timestamp
        properties[tokenId] = PropertyInfo(
            _totalSupply,
            _pricePerToken,
            block.timestamp + 1 weeks,
            false
        );

        emit Mint(tokenId, msg.sender, _totalSupply, _tokenUri);

        // mint tokens
        _mint(msg.sender, tokenId, _totalSupply, "");
        return tokenId;
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
        @notice to return the MetaDataURI of the NFT 
        @param _id token id of the NFT
        
    */

    function uri(uint256 _id)
        public
        view
        override(ERC1155)
        returns (string memory)
    {
        return _tokenURIs[_id];
    }

    /**
        @notice setting URI of token
        @param _id token id of the NFT
        @param _uri MetaDataURI of the NFT
    */
    function _setURI(uint256 _id, string memory _uri) internal {
        _tokenURIs[_id] = _uri;
    }

    function _beforeTokenMint(
        address _reciever,
        uint256 _amount,
        string calldata _uri
    ) internal pure {
        require(_reciever != address(0), "beforeTokenMint: Invalid Receiver");
        require(_amount != 0, "beforeTokenMint: amount == 0");
        require(bytes(_uri).length != 0, "beforeTokenMint: Empty URI");
    }
}
