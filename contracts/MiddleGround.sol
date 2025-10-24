// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "TokenFactory.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


// ✅ Interface for the target contract (the one you want to call)
interface ITokenSale {
    function buyTokens(
        address onBehalfOf,
        uint256 id,
        uint256 amount,
        address ref
    ) external;
}

contract MiddleGround is ReentrancyGuard, AccessControlDefaultAdminRules, Pausable{

    ITokenSale public coreContract;

    address public paymentToken;

    uint256 public txId;

    mapping(uint256 => InvestmentTx) tx;


    struct InvestmentTx{
        uint256 id;
        address onBehalfOf;
        address ref;
        uint256 amount;
        uint256 status;
    }

    constructor(address paymentToken_, address coreContract_)  AccessControlDefaultAdminRules(
    3 days,
    msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
    ){

        paymentToken = paymentToken_;
        coreContract = ITokenSale(coreContract_);
    }


    function buyTokens(
        address onBehalfOf,
        uint256 id,
        uint256 amount,
        address ref
    ) external nonReentrant whenNotPaused{

        // Charge investment cost from user
        SafeERC20.safeTransferFrom(paymentToken,msg.sender, address(this), amount);

        tx[txId] = InvestmentTx(txId, onBehalfOf, ref, amount, 0);

        txId++;

    }

    function executeInvestment(uint256 id) external onlyRole(DEFAULT_ADMIN_ROLE){

        coreContract.buyTokens(tx[id].onBehalfOf, tx[id].id, tx[id].amount, tx[id].ref);

        emit TokensBought(msg.sender, onBehalfOf, id, amount, ref);

        tx[txId].status = 1;

    }

    function returnInvestment(
        uint256 id
    ) external nonReentrant whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE){

        require(tx[txId].status == 0,"Already returned or concluded the investment");

        tx[txId].status = 2;


    }

    function changePaymentToken(address newToken) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(newToken != address(0), "Invalid Token");
        paymentToken = newToken;
    }

        /**
        @dev    Pause all Hesty Contracts
        @dev    Require this approval to allow users move Hesty derivatives
                onlyOnwer
    */
        function pause() external onlyRole(DEFAULT_ADMIN_ROLE){
        super._pause();
        }

        /**
        @dev    Unpause all Hesty Contracts
        @dev    Require this approval to allow users move Hesty derivatives
                onlyOnwer
    */
        function unpause() external onlyRole(DEFAULT_ADMIN_ROLE){
        super._unpause();
        }
}
