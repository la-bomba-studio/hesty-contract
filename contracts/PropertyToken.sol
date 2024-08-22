// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/**
 * @title   Property Token
 *
 * @notice  Token associated to a property that tracks
            investors and stakeholders that are entitled
            to a share of the property generated revenue.
 *
 * @dev     {ERC20} token, including:
 *
 *          - Pre minted initial supply
 *          - Ability for holders to burn (destroy) their tokens
 *          - No access control mechanism (for minting/pausing) and hence no governance
 *
 *
 * Developed by Pedro Ferreira
 */
contract PropertyToken is ERC20{

    uint256 private constant    BASIS_POINTS = 10000; //BASIS POINTS used for % math calculations
    uint32  private constant    MULTIPLIER   = 1e9; // Multiplier to guarantee math safety in gwei, everything else is neglectable
    uint256 public              dividendPerToken; //Dividends per share/token
    mapping(address => uint256) public xDividendPerToken; //Last user dividends essential to calculate future rewards

    public address admin;

    IERC20  public rewardAsset;

    modifier onlyAdmin(){
        require(msg.sender == admin, "Not Admin");
        _;
    }

    /**
    * @dev Mints x amount of tokens and transfers them to each Multisig wallet/Vesting Contract according to the tokenomics
    *
    * See {ERC20-constructor}.
    */
    constructor(
        address tokenManagerContract_,
        uint256 initialSupply_,
        string memory  name_,
        string memory symbol_,
        address rewardAsset_
        address admin_
    ) ERC20(name_, symbol_) {

        //Pre-Seed Share
        _mint(address(tokenManagerContract_), initialSupply_ * 1 ether);

        rewardAsset = IERC20(rewardAsset_);

        admin = admin_;

    }


    function distributionRewards(uint256 amount) external{

        require(amount > BASIS_POINTS, "Amount too low");

        (bool success) = rewardAsset.transferFrom(msg.sender, address(this), amount);

        require(success, "Failed Transfer");

        dividendPerToken += amount * MULTIPLIER / super.totalSupply();

    }

    function claimDividensExternal(address acc) external{
        claimDividends(payable(acc));
    }

    function claimDividends(address payable account) private{

        uint256 amount             = ( (dividendPerToken - xDividendPerToken[account]) * balanceOf(account) / MULTIPLIER);
        xDividendPerToken[account] = dividendPerToken;

        if(amount > 0){
            (bool success) = rewardAsset.transfer(account, amount);
            require(success, "Failed Transfer");
        }

    }

    function transfer(address to, uint256 amount) override public returns(bool){

        claimDividends(payable(msg.sender));
        claimDividends(payable(to));
        return super.transfer(to, amount);
    }


    function transferFrom(address from, address to, uint256 amount) override public returns(bool){
        claimDividends(payable(from));
        claimDividends(payable(to));
        return super.transfer(to, amount);
    }
}