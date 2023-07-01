// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./interfaces/IPropertyToken.sol";

error SaleAlreadyStarted();
error SaleAlreadyEnded();

contract HestyITOContract is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC1155HolderUpgradeable,
    AccessControlUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal _listingIds;

    uint256 platformThreshold;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20Upgradeable public euroCoinAddress;

    enum PaymentMode {
        MATIC,
        EUROCOIN
    }

    enum ListingStatus {
        LISTED,
        SOLD,
        CANCELLED
    }

    ListingStatus constant defaultListingStatus = ListingStatus.LISTED;

    struct PropertyDetail {
        address propertyAddress;
        address propertyOwner;
        address secondaryOwner;
        uint256 propertyId;
        uint256 listingId;
    }

    struct ListDetail {
        uint256 listingId;
        uint256 amountOfTokensListed;
        uint256 amountOfTokensSold;
        uint256 pricePerToken;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 lastUpdated;
        uint256 partnerThreshold;
        PaymentMode mode;
        ListingStatus status;
    }

    mapping(uint256 => PropertyDetail) public propertyDetails;
    mapping(uint256 => ListDetail) public listDetails;

    event PropertyListedOnSale(
        address propertyAddress,
        address propertyOwner,
        address secondaryOwner,
        uint256 propertyId,
        uint256 listingId,
        uint256 amountOfTokensListed,
        uint256 pricePerToken,
        uint256 saleStart,
        uint256 saleEnd,
        uint256 partnerThreshold,
        PaymentMode mode
    );

    event PropertyPurchasedFromSale(
        uint256 listingId,
        address buyerAddress,
        uint256 amountOfTokensPurchased
    );

    event SaleUpdated(
        uint256 listingId,
        address propertyAddress,
        uint256 propertyId,
        uint256 pricePerToken,
        uint256 saleStart,
        uint256 saleEnd,
        uint256 partnerThreshold
    );

    event SaleCancelled(
        uint256 listingId,
        address propertyAddress,
        uint256 propertyId
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
        @notice Initialize: Initialize a smart contract
        @dev Works as a constructor for proxy contracts
        @param _admin Admin wallet address
     */
    function initialize(address _admin) external initializer {
        __Ownable_init();
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _admin);
    }

    /** 
        @notice UUPS upgrade mandatory function: To authorize the owner to upgrade 
                the contract
    */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    modifier onlyPropertyManagers(
        address _propertyAddress,
        uint256 _propertyId,
        address _userAddress
    ) {
        require(
            IPropertyToken(_propertyAddress).checkIsManager(
                _propertyId,
                _userAddress
            ),
            "onlyPropertyManagers: only property managers can list"
        );
        _;
    }

    function listNFTOnSale(
        address _propertyAddress,
        uint256 _propertyId,
        uint256 _amountOfTokensToList,
        uint256 _pricePerToken,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        uint256 _partnerThreshold,
        PaymentMode _mode
    ) external onlyPropertyManagers(_propertyAddress, _propertyId, msg.sender) {
        _checkBeforeListingForSale(
            _propertyAddress,
            _propertyId,
            _saleStartTime,
            _saleEndTime,
            _amountOfTokensToList
        );
        _listingIds.increment();
        uint256 _listingId = _listingIds.current();

        _updatePropertyDetail(_propertyAddress, _propertyId, _listingId);
        _updateListDetail(
            _listingId,
            _amountOfTokensToList,
            _pricePerToken,
            _saleStartTime,
            _saleEndTime,
            _partnerThreshold,
            _mode
        );

        IERC1155Upgradeable(_propertyAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _propertyId,
            _amountOfTokensToList,
            "0x00"
        );

        emit PropertyListedOnSale(
            _propertyAddress,
            msg.sender,
            msg.sender,
            _propertyId,
            _listingId,
            _amountOfTokensToList,
            _pricePerToken,
            _saleStartTime,
            _saleEndTime,
            _partnerThreshold,
            _mode
        );
    }

    function purchasePropertyFromSale(
        uint256 _listingId,
        uint256 _amountOfTokensToPurchase
    ) external payable {
        _checkBeforePurchasingFromSale(_listingId, _amountOfTokensToPurchase);
        PropertyDetail storage _propertyDetail = propertyDetails[_listingId];
        ListDetail storage _listDetail = listDetails[_listingId];
        uint256 _totalInvoice = _amountOfTokensToPurchase *
            _listDetail.pricePerToken;

        if (_listDetail.mode == PaymentMode.MATIC) {
            require(msg.value == _totalInvoice);
        } else if (_listDetail.mode == PaymentMode.EUROCOIN) {
            require(
                IERC20Upgradeable(euroCoinAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _totalInvoice
                )
            );
        }

        _listDetail.amountOfTokensSold += _amountOfTokensToPurchase;
        _propertyDetail.secondaryOwner = msg.sender;
        _listDetail.status = ListingStatus.SOLD;

        IERC1155Upgradeable(_propertyDetail.propertyAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _propertyDetail.propertyId,
            _amountOfTokensToPurchase,
            "0x00"
        );

        emit PropertyPurchasedFromSale(
            _listingId,
            msg.sender,
            _amountOfTokensToPurchase
        );
    }

    function updateOngoingSale(
        uint256 _listingId,
        address _propertyAddress,
        uint256 _propertyId,
        uint256 _pricePerToken,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _partnerThreshold
    ) external onlyPropertyManagers(_propertyAddress, _propertyId, msg.sender) {
        _checkBeforeUpdatingSale(
            _listingId,
            _pricePerToken,
            _saleStart,
            _saleEnd,
            _partnerThreshold
        );
        ListDetail storage _listDetail = listDetails[_listingId];
        _listDetail.pricePerToken = _pricePerToken;
        if (_listDetail.saleStart >= block.timestamp) {
            _listDetail.saleStart = _saleStart;
        } else {
            revert SaleAlreadyStarted();
        }
        if (_listDetail.saleEnd <= block.timestamp) {
            _listDetail.saleEnd = _saleEnd;
        } else {
            revert SaleAlreadyEnded();
        }

        emit SaleUpdated(
            _listingId,
            _propertyAddress,
            _propertyId,
            _pricePerToken,
            _saleStart,
            _saleEnd,
            _partnerThreshold
        );
    }

    function cancelOngoingSale(
        uint256 _listingId,
        address _propertyAddress,
        uint256 _propertyId
    ) public onlyPropertyManagers(_propertyAddress, _propertyId, msg.sender) {
        _checkBeforeCancellingSale(_listingId, _propertyAddress, _propertyId);
        PropertyDetail storage _propertyDetail = propertyDetails[_listingId];
        ListDetail storage _listDetail = listDetails[_listingId];
        _listDetail.status = ListingStatus.CANCELLED;
        uint256 _amountOfTokensLeft = _listDetail.amountOfTokensListed -
            _listDetail.amountOfTokensSold;
        require(
            IPropertyToken(_propertyAddress).balanceOf(
                address(this),
                _propertyId
            ) > _amountOfTokensLeft,
            "cancelOngoingSale: Out of balance"
        );
        IPropertyToken(_propertyAddress).safeTransferFrom(
            address(this),
            _propertyDetail.propertyOwner,
            _propertyId,
            _amountOfTokensLeft,
            "0x00"
        );

        emit SaleCancelled(_listingId, _propertyAddress, _propertyId);
    }

    function checkForPlatformThreshold(
        uint256 _listingId
    ) public view returns (bool) {
        ListDetail memory _listDetail = listDetails[_listingId];
        bool _resultant;
        uint256 _tokensListed = _listDetail.amountOfTokensListed;
        uint256 _tokensSold = _listDetail.amountOfTokensSold;
        uint256 _checkForThreshold = (_tokensListed * platformThreshold) /
            10000;
        if (_tokensSold >= _checkForThreshold) {
            _resultant = true;
        } else {
            _resultant = false;
        }
        return _resultant;
    }

    function checkForPartnerThreshold(
        uint256 _listingId
    ) external view returns (bool) {
        require(
            checkForPlatformThreshold(_listingId) == true,
            "checkForPartnerThreshold: PlatformThreshold not reached"
        );
        ListDetail memory _listDetail = listDetails[_listingId];
        bool _resultant;
        uint256 _tokensLeft = _listDetail.amountOfTokensListed -
            _listDetail.amountOfTokensSold;
        uint256 _checkForThreshold = (_tokensLeft *
            _listDetail.partnerThreshold) / 10000;
        if (_tokensLeft >= _checkForThreshold) {
            _resultant = true;
        } else {
            _resultant = false;
        }
        return _resultant;
    }

    // exmaple: 20% -> then input should be -> 2000
    function setPlatformThreshold(
        uint256 _thresholdPercentage
    ) external onlyRole(ADMIN_ROLE) {
        require(
            _thresholdPercentage != 0,
            "setPlatformThreshold: _thresholdPercentage cannot be zero"
        );
        platformThreshold = _thresholdPercentage;
    }

    function setEuroCoinAddress(
        address _euroCoinAddress
    ) external onlyRole(ADMIN_ROLE) {
        euroCoinAddress = IERC20Upgradeable(_euroCoinAddress);
    }

    function _checkBeforeListingForSale(
        address _propertyAddress,
        uint256 _propertyId,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        uint256 _amountOfTokensToList
    ) internal view {
        require(
            _saleStartTime != 0 && _saleStartTime >= block.timestamp,
            "_checkBeforeListingForSale: start time should be greater than timsestamp"
        );
        require(
            _saleEndTime != 0 && _saleEndTime >= block.timestamp,
            "_checkBeforeListingForSale: start time should be greater than timsestamp"
        );
        require(
            _propertyAddress != address(0),
            "_checkBeforeListingForSale: property address can not be zero address"
        );
        require(
            _amountOfTokensToList != 0,
            "_checkBeforeListingForSale: amount to list can not be zero"
        );
        require(
            IPropertyToken(_propertyAddress).exists(_propertyId),
            "_checkBeforeListingForSale: Property does not exists"
        );
    }

    function _checkBeforePurchasingFromSale(
        uint256 _listingId,
        uint256 _amountOfTokensToPurchase
    ) internal view {
        ListDetail memory _listDetail = listDetails[_listingId];
        require(
            _listDetail.status == ListingStatus.LISTED,
            "_checkBeforePurchasingFromSale: Property is SOLD or CANCELLED"
        );
        require(
            _listDetail.listingId != 0 && _amountOfTokensToPurchase != 0,
            "_checkBeforePurchasingFromSale: _listingId & _amountOfTokensToPurchase can not be zero"
        );
        require(
            _listDetail.saleStart >= block.timestamp,
            "_checkBeforePurchasingFromSale: Sale not started yet"
        );
        require(
            _listDetail.saleEnd < block.timestamp,
            "_checkBeforePurchasingFromSale: Sale ended"
        );
    }

    function _checkBeforeUpdatingSale(
        uint256 _listingId,
        uint256 _pricePerToken,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _partnerThreshold
    ) internal view {
        require(
            _listingId != 0,
            "_checkBeforeUpdatingSale: listing Id cannot be zero"
        );
        require(
            _pricePerToken != 0,
            "_checkBeforeUpdatingSale: listing Id cannot be zero"
        );
        require(
            _saleStart != _saleEnd,
            "_checkBeforeUpdatingSale: start & end can not be same"
        );
        require(
            _saleStart != 0 && _saleStart >= block.timestamp,
            "_checkBeforeUpdatingSale: listing Id cannot be zero"
        );
        require(
            _saleEnd != 0 && _saleStart >= block.timestamp,
            "_checkBeforeUpdatingSale: listing Id cannot be zero"
        );
        require(
            _partnerThreshold != 0,
            "_checkBeforeUpdatingSale: listing Id cannot be zero"
        );
    }

    function _checkBeforeCancellingSale(
        uint256 _listingId,
        address _propertyAddress,
        uint256 _propertyId
    ) internal pure {
        require(
            _listingId != 0,
            "_checkBeforeCancellingSale: listing Id cannot be zero"
        );
        require(
            _propertyAddress != address(0),
            "_checkBeforeCancellingSale: property address cannot be zero"
        );
        require(
            _propertyId != 0,
            "_checkBeforeCancellingSale: propertyId can not be zero"
        );
    }

    function _updatePropertyDetail(
        address _propertyAddress,
        uint256 _propertyId,
        uint256 _listingId
    ) internal {
        PropertyDetail storage _propertyDetail = propertyDetails[_listingId];
        _propertyDetail.propertyAddress = _propertyAddress;
        _propertyDetail.propertyId = _propertyId;
        _propertyDetail.propertyOwner = msg.sender;
        _propertyDetail.secondaryOwner = msg.sender;
        _propertyDetail.listingId = _listingId;
    }

    function _updateListDetail(
        uint256 _listingId,
        uint256 _amountOfTokensToList,
        uint256 _pricePerToken,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        uint256 _partnerThreshold,
        PaymentMode _mode
    ) internal {
        PropertyDetail storage _propertyDetail = propertyDetails[_listingId];
        ListDetail storage _listDetail = listDetails[_listingId];
        _listDetail.listingId = _listingId;
        _listDetail.amountOfTokensListed = _amountOfTokensToList;
        _listDetail.amountOfTokensSold = 0;
        _listDetail.pricePerToken = _pricePerToken;
        _listDetail.saleStart = _saleStartTime;
        _listDetail.saleEnd = _saleEndTime;
        _listDetail.lastUpdated = block.timestamp;
        _listDetail.partnerThreshold = _partnerThreshold;
        _listDetail.mode = _mode;
        _listDetail.status = defaultListingStatus;
        IPropertyToken(_propertyDetail.propertyAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _propertyDetail.propertyId,
            _amountOfTokensToList,
            "0x00"
        );
    }

    /**@notice Mandatory function overriding for inherited contract
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155ReceiverUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
