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
        _mint(address(tokenManagerContract_), initialSupply_);

    }
}