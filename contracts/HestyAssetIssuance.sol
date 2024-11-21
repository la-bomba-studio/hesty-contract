// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PropertyToken} from "./PropertyToken.sol";
import {IIssuance} from "./interfaces/IIssuance.sol";
/*
*
*   @title Hesty Asset Issuance
*
*   @notice Issues a Token with the required properties
*
*   @author Pedro G. S. Ferreira

*/

contract HestyAssetIssuance is IIssuance{

    address public tokenFactory;

    constructor(address tokenFactory_){
        tokenFactory = tokenFactory_;
    }

    /**
        @dev    Issues a new property token
        @dev    It emits a `CreateProperty` event.
    */
    function createPropertyToken(
        uint256 amount,
        address revenueToken,
        string memory name,
        string memory symbol,
        address admin,
        address owner

    ) external override(IIssuance) returns(address) {
        require(msg.sender == tokenFactory, "Not TokenFactory");

        return  address(
            new PropertyToken(tokenFactory,
                amount,
                name,
                symbol,
                address(revenueToken),
                admin,
                owner ));
    }

}