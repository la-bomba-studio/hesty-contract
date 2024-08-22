pragma solidity ^0.8.0;

import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/**
* Property Contract
* @notice Allows property owners to distribute and store rewards
*         owned to investors/stakeholders and distributes them
*         to the same investors/stakeholders
*
*         Developed by Pedro G. S. Ferreira @Pedro_Ferreir_a
*/
contract Vault is ERC4626, ReentrancyGuard{

    uint32  private constant MULTIPLIER = 1e9; // Multiplier to guarantee math safety in gwei

    mapping(address => uint256)  public xDividendPerToken; /// @notice
    mapping (address => uint256) public credit;  /// @notice Amount that should have been withdrawn
    mapping (address => uint256) public debt;

    uint256 public dividendPerToken; //Dividends per share/token
    IERC20  public rewardAsset;

    constructor(IERC20 asset_, address rewardAsset_) ERC4626(asset_) ERC20("asset1", "asset"){
        rewardAsset = IERC20(rewardAsset_);
    }

    function distributeRewards(uint256 amount) external nonReentrant{

        require(amount > 0, "Amount Invalid");

        (bool success) = rewardAsset.transferFrom(msg.sender, address(this), amount);

        require(success, "Failed Transfer");

        //totalsupply must be higher than 0 but tht is inforced from the deploy
        dividendPerToken += amount * MULTIPLIER / totalSupply();

    }

    function withdrawRewards(address user)  external nonReentrant returns(uint256) {

        uint256 holderBalance = balanceOf(user);

        require(holderBalance != 0, "Caller possess no shares");

        uint256 amount = ( (dividendPerToken - xDividendPerToken[msg.sender]) * holderBalance / MULTIPLIER);

        amount                  += credit[user];
        credit[user]            = 0;
        xDividendPerToken[user] = dividendPerToken;


        (bool success) = rewardAsset.transfer(user, amount);
        require(success, "Send failed");


        return amount;

    }

    function _decimalsOffset() internal override view virtual returns (uint8) {
        return 8;
    }

}
