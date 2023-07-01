// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PropertyTokenFactory is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter public propertyCreationCounter;
    bytes32 public constant HESTY_ADMIN_ROLE = keccak256("HESTY_ADMIN_ROLE");

    struct PropertyDetail {
        uint256 id;
        address ownerAddress;
        address propertyAddress;
        uint256 salt;
        string baseURI;
        uint256 createdOn;
    }

    mapping(address => mapping(uint256 => PropertyDetail))
        internal propertyDetails;
    mapping(address => uint256[]) internal propertyCreationIds;

    event NewPropertyCreated(
        uint256 id,
        address propertyOwnerAddress,
        string baseURI,
        uint256 salt,
        address propertyAddress
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**@notice intializer for proxy - replacement to constructor
     */
    function initialize(address _hestyAdmin) external initializer {
        _setRoleAdmin(HESTY_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setupRole(DEFAULT_ADMIN_ROLE, _hestyAdmin);
        _setupRole(HESTY_ADMIN_ROLE, _hestyAdmin);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /// @notice UUPS upgrade mandatory function: To authorize the owner to upgrade the contract
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function getChildAddressBeforeDeployment(
        bytes memory _byteCode,
        uint256 _salt
    ) public view returns (address) {
        bytes32 addressHash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(_byteCode)
            )
        );
        return address(uint160(uint(addressHash)));
    }

    function getBytecode(
        string memory _baseURI
    ) public pure returns (bytes memory) {
        bytes memory _bytecode = type(ChildPropertyContract).creationCode;
        return abi.encodePacked(_bytecode, abi.encode(_baseURI));
    }

    function getListOfPropertiesPerOwner(
        address _propertyOwner,
        uint256 _id
    ) external view returns (PropertyDetail memory) {
        return propertyDetails[_propertyOwner][_id];
    }

    function createChildProperty(
        address _propertyOwnerAddress,
        string calldata _baseURI,
        uint256 _salt
    ) external onlyRole(HESTY_ADMIN_ROLE) returns (address) {
        ChildPropertyContract _newChildBatch = new ChildPropertyContract{
            salt: bytes32(_salt)
        }(_propertyOwnerAddress, _baseURI);

        propertyCreationCounter.increment();
        uint256 _propertyCreationId = propertyCreationCounter.current();

        propertyCreationIds[_propertyOwnerAddress].push(_propertyCreationId);
        PropertyDetail storage _detail = propertyDetails[_propertyOwnerAddress][
            _propertyCreationId
        ];

        _detail.id = _propertyCreationId;
        _detail.ownerAddress = _propertyOwnerAddress;
        _detail.propertyAddress = address(_newChildBatch);
        _detail.salt = _salt;
        _detail.baseURI = _baseURI;
        _detail.createdOn = block.timestamp;

        emit NewPropertyCreated(
            _propertyCreationId,
            _propertyOwnerAddress,
            _baseURI,
            _salt,
            address(_newChildBatch)
        );
        return address(_newChildBatch);
    }
}

contract ChildPropertyContract is ERC1155Supply, AccessControl {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter public _propertyTokenIds;

    bytes32 public constant PROPERTY_ADMIN_ROLE =
        keccak256("PROPERTY_ADMIN_ROLE");

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(uint256 => string) private _tokenURIs;

    mapping(uint256 => address[]) private propertyManagerList;

    event PropertyURIUpdated(uint256 propertyId, string updatedURI);

    constructor(
        address _propertyOwner,
        string memory _baseURI
    ) ERC1155(_baseURI) {
        _setRoleAdmin(PROPERTY_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, PROPERTY_ADMIN_ROLE);
        _setupRole(DEFAULT_ADMIN_ROLE, _propertyOwner);
        _setupRole(PROPERTY_ADMIN_ROLE, _propertyOwner);
        _setupRole(MANAGER_ROLE, _propertyOwner);
    }

    /**
        @notice to return the MetaDataURI of the NFT 
        @param _id token id of the NFT
    */
    function uri(
        uint256 _id
    ) public view override(ERC1155) returns (string memory) {
        return _tokenURIs[_id];
    }

    function getProeprtyManagersList(
        uint256 _propertyId
    ) external view returns (address[] memory) {
        return propertyManagerList[_propertyId];
    }

    function checkIsManager(
        uint256 _propertyId,
        address _userAddress
    ) external view returns (bool) {
        require(_propertyId != 0, "checkIsManager: propertyId can not be zero");
        bool _result;
        for (uint256 i = 0; i < propertyManagerList[_propertyId].length; ) {
            if (propertyManagerList[_propertyId][i] == _userAddress) {
                _result = true;
            }
            unchecked {
                ++i;
            }
        }
        return _result;
    }

    /**
        @notice minting new project tokens
        @dev calls 1155 _mint funcntion after validating the parameters
        @param _reciever NFT reciever 
        @param _amount number of copies
        @param _uri MetaDataURI of the NFT
    */
    function mintPropertyToken(
        address _reciever,
        uint256 _amount,
        string calldata _uri
    ) external onlyRole(MANAGER_ROLE) {
        _beforeTokenMint(_reciever, _amount, _uri);
        _propertyTokenIds.increment();
        uint256 _propertyTokenId = _propertyTokenIds.current();
        _setURI(_propertyTokenId, _uri);
        _mint(_reciever, _propertyTokenId, _amount, "");
    }

    function updatePropertyURI(
        uint256 _propertyId,
        string calldata _updatedURI
    ) external onlyRole(MANAGER_ROLE) {
        _setURI(_propertyId, _updatedURI);
        emit PropertyURIUpdated(_propertyId, _updatedURI);
    }

    function grantRole(
        bytes32 _role,
        address _account,
        uint256 _propertyId
    ) public virtual onlyRole(getRoleAdmin(_role)) {
        propertyManagerList[_propertyId].push(_account);
        super.grantRole(_role, _account);
    }

    /**
        @notice setting URI of token
        @param _id token id of the NFT
        @param _uri MetaDataURI of the NFT
    */
    function _setURI(uint256 _id, string memory _uri) internal {
        require(_id != 0, "_setURI: _id can not be zero");
        require(bytes(_uri).length != 0, "_setURI: _uri can not be zero");
        _tokenURIs[_id] = _uri;
    }

    /**@notice making checks before token mint
        @param _reciever receiver address
        @param _amount amount to mint
        @param _uri token URI
    */
    function _beforeTokenMint(
        address _reciever,
        uint256 _amount,
        string calldata _uri
    ) internal pure {
        require(_reciever != address(0), "beforeTokenMint: Invalid Receiver");
        require(_amount != 0, "beforeTokenMint: amount == 0");
        require(bytes(_uri).length != 0, "beforeTokenMint: Empty URI");
    }

    /**@notice Mandatory function overriding for inherited contract
     */
    function _msgSender()
        internal
        view
        virtual
        override(Context)
        returns (address)
    {
        return msg.sender;
    }

    /**@notice Mandatory function overriding for inherited contract
     */
    function _msgData()
        internal
        view
        virtual
        override(Context)
        returns (bytes calldata)
    {
        return msg.data;
    }

    /**@notice Mandatory function overriding for inherited contract
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
