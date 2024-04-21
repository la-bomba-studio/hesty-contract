pragma solidity ^0.8.0;

import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Property is ERC4626, ReentrancyGuard{

    //Multiplier to garantee math safety
    uint32 constant private MULTIPLIER = 1e9; // in gwei

    //Dividends per share/token
    uint256 dividendPerToken;

    //
    mapping(address => uint256) xDividendPerToken;

    /// @notice Amount that should have been withdrawn
    mapping (address => uint256) credit;

    mapping (address => uint256) debt;

    IERC20 rewardAsset;

    constructor(IERC20 asset_, IERC20 rewardAsset_) ERC4626(asset_) ERC20("asset1", "asset"){
        rewardAsset = rewardAsset_;
    }

    function distributeRewards(uint256 amount) external nonReentrant{

        require(amount > 0, "Amount Invalid");

        (bool success) = rewardAsset.transferFrom(msg.sender, address(this), amount);

        require(success, "Failed Transfer");

        //totalsupply must be higher than 0 but tht is inforced from the deploy
        dividendPerToken += amount * MULTIPLIER / totalSupply();

    }

    function withdrawRewards() external nonReentrant{

        uint256 holderBalance = balanceOf(msg.sender);

        require(holderBalance != 0, "Caller possess no shares");

        uint256 amount = ( (dividendPerToken - xDividendPerToken[msg.sender]) * holderBalance / MULTIPLIER);

        amount += credit[msg.sender];

        credit[msg.sender] = 0;

        xDividendPerToken[msg.sender] = dividendPerToken;

        (bool success) = rewardAsset.transfer(msg.sender, amount);

        require(success, "Couldn't withdraw Asset");

    }

    function _decimalsOffset() internal override view virtual returns (uint8) {
        return 8;
    }

}
