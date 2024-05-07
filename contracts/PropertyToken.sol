// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - Pre minted initial supply
 *  - Ability for holders to burn (destroy) their tokens
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *
 * This contract uses {ERC20Burnable} to include burn capabilities
 */
contract PropertyToken is ERC20{


    uint256 private constant  BASIS_POINTS = 10000;

    //Multiplier to garantee math safety
    uint32 constant private MULTIPLIER = 1e9; // in gwei

    //Dividends per share/token
    uint256 dividendPerToken;

    //Last user dividends essential to calculate future rewards
    mapping(address => uint256) xDividendPerToken;


    /**
    * @dev Mints x amount of tokens and transfers them to each Multisig wallet/Vesting Contract according to the tokenomics
    *
    * See {ERC20-constructor}.
    */
    constructor(
        address tokenManagerContract_,
        uint256 initialSupply_,
        string memory  name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {

        //Pre-Seed Share
        _mint(address(tokenManagerContract_), initialSupply_ * 1 ether);

    }


    function distributionRewards() payable external{

        require(msg.value > BASIS_POINTS, "Amount too low");

        dividendPerToken += msg.value * MULTIPLIER / super.totalSupply();

    }

    function claimDividensExternal(address acc) external{
        claimDividends(payable(acc));
    }

    function claimDividends(address payable account) private{

        uint256 amount = ( (dividendPerToken - xDividendPerToken[account]) * balanceOf(account) / MULTIPLIER);

        xDividendPerToken[account] = dividendPerToken;

        if(amount > 0){
            (bool success,) = account.call{value:amount}("");
            require(success,"Fail transfer");
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