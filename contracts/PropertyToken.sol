// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "./interfaces/IHestyAccessControl.sol";
import "./Constants.sol";

/**
    @title   Property Token

    @notice  Token associated to a property that tracks
            investors and stakeholders that are entitled
            to a share of the property generated revenue.

    @dev     {ERC20} token, including:

            - Minted initial supply in constructor

    @author Pedro G. S. Ferreira
 */
contract PropertyToken is ERC20Pausable, AccessControlDefaultAdminRules, Constants{

    IERC20  public rewardAsset;                 // Reward Token (EURC)
    IHestyAccessControl public ctrHestyControl; // Hesty Access Control Contract

    uint256 public dividendPerToken;            // Dividends per share/token

    mapping(address => uint256) public xDividendPerToken;   // Last user dividends essential to calculate future rewards

    /**======================================

    MODIFIER FUNCTIONS

    =========================================**/

    /**
        @dev Checks that onlyPauser can call the function
    */
    modifier onlyPauser(address manager){
        require(hasRole(PAUSER_MANAGER, manager), "Not Pauser");
        _;
    }

    /**
        @dev Checks that `user` is not blacklisted
    */
    modifier whenNotBlackListed(address user){
        require(!ctrHestyControl.blackList(user), "Blacklisted");
        _;
    }

    /**
        @dev Checks that `user` has KYC approved
    */
    modifier whenKYCApproved(address user){
        require(ctrHestyControl.kycCompleted(user), "No KYC Made");
        _;
    }

    /**
        @dev Checks that hesty contracts are not all paused
    */
    modifier whenNotAllPaused(){
        require(!ctrHestyControl.paused(), "All Hesty Paused");
        _;
    }

    /**
        @dev    Mints initialSupply_ * 1 ether of tokens and transfers them
                to Token Factory
        @param  tokenManagerContract_ Contract that will manage initial issued supply
        @param  initialSupply_ Initial Property Token Supply
        @param  name_ Token Name
        @param  symbol_ Token Symbol/Ticker
        @param  rewardAsset_ Token that will distributed through holders has an investment return (EURC)
        @param  ctrHestyControl_ Contract that has the power to manage access to the token
    *
    * See {ERC20-constructor}.
    */
    constructor(
        address tokenManagerContract_,
        uint256 initialSupply_,
        string memory  name_,
        string memory symbol_,
        address rewardAsset_,
        address ctrHestyControl_,
        address owner
    ) ERC20(name_, symbol_) AccessControlDefaultAdminRules(
    3 days,
     owner // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

        // Supplies higher than TEN_POWER_FIFTEEN ether will result in precision lost
        require(initialSupply_ < TEN_POWER_FIFTEEN, "Precision lost");

        // Property Token Supply Issuance
        _mint(address(tokenManagerContract_), initialSupply_ * 1 ether);

        rewardAsset     = IERC20(rewardAsset_);
        ctrHestyControl = IHestyAccessControl(ctrHestyControl_);

    }

    /**======================================

    MUTABLE FUNCTIONS

    =========================================**/

    /**
        @dev    Claims users dividends
        @param  amount Token Amount that users wants to buy
    */

    function distributionRewards(uint256 amount) external whenNotPaused{

        require(amount > BASIS_POINTS, "Amount too low");

        SafeERC20.safeTransferFrom(rewardAsset, msg.sender, address(this), amount);

        dividendPerToken += amount * MULTIPLIER / super.totalSupply();

    }

    /**
    * @notice Claims users dividends
      @param  user User Address that will receive dividends
    */
    function claimDividensExternal(address user) external whenNotPaused{
        claimDividends(user);
    }

    /**
        @notice Claims users dividends
        @param  account The account that will receive dividends
          @dev Checks if there is any dividends to distribute
               and send them directly to the wallet

               The math logic is simple:

               - dividendPerToken keeps track of all time rewards
                 per token distributed to holders
               - xDividendPerToken keeps track of users already
                 claimed rewards
               - xDividendPerToken is updated before each transfer
                 to be able to keep track of the math for each wallet
               - Multiplier is just an helper to keep math precision

                Using multiplier helper keeps it simple
                but is not 100% precsie, but what is lost
                is neglectable
    */
    function claimDividends(address account) private{

        uint256 amount             = ( (dividendPerToken - xDividendPerToken[account]) * balanceOf(account) / MULTIPLIER);
        xDividendPerToken[account] = dividendPerToken;

        if(amount > 0){
            SafeERC20.safeTransfer(rewardAsset, account, amount);
        }

    }

    /**
  * @dev Transfers users tokens from address msg.sender
           to address "to" using openzepplin standard
           but implements two internal Hesty mechanism:

           - A KYC requirement
           - Claims dividends to both addresses involved in
             in the transfer before transfer is completed
             to avoid math overhead
    *
    * See {ERC20-constructor}.
    */
    function transfer(address to, uint256 amount) override
                        whenNotBlackListed(to) whenKYCApproved(to) whenNotAllPaused() whenNotPaused public returns(bool){

        claimDividends(msg.sender);
        claimDividends(to);
        return super.transfer(to, amount);
    }

    /**
  * @dev Transfers users tokens from address "from"
           to address "to" using openzepplin standard
           but implements multiple internal Hesty mechanism:

           - A KYC requirement
           - A blacklist requirement
           - Claims dividends to both addresses involved in
             in the transfer before transfer is completed
             to avoid math overhead
            This function implements two types of pause
            an unique pause and a pause dependent on HestyAccessControl
    *
    * See {ERC20-constructor}.
    */
    function transferFrom(address from, address to, uint256 amount) override
                           whenNotBlackListed(to) whenKYCApproved(to) whenNotAllPaused() whenNotPaused public returns(bool){

        claimDividends(from);
        claimDividends(to);
        return super.transferFrom(from, to, amount);
    }

    /**
        @dev Pauses Property Token Only
    */
    function pause() external onlyPauser(msg.sender){
        super._pause();
    }

    /**
        @dev Unpauses Property Token Only
    */
    function unpause() external onlyPauser(msg.sender){
        super._unpause();
    }
}