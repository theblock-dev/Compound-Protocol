// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CTokenInterface.sol";

interface ComptrollerInterface {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    
    function isComptroller() external view returns (bool);

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cToken) external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address cToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address cToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address cToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address cToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

contract Compound {
  IERC20 dai;
  CTokenInterface cDai;
  IERC20 bat;
  CTokenInterface cBat;
  ComptrollerInterface comptroller;

  constructor(address _dai, address _cDai, address _bat, address _cbat, address _comptroller){
    dai = IERC20(_dai);
    cDai = CTokenInterface(_cDai);
    bat = IERC20(_bat);
    cBat = CTokenInterface(_cbat);
    comptroller = ComptrollerInterface(_comptroller);    
  }

  function invest() external {
    dai.approve(address(cDai), 1000); //external caller
    cDai.mint(1000);
  }

  function redeem() external {
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);
  }

  function borrow() external {
    dai.approve(address(cDai), 1000); //external caller
    cDai.mint(1000);
    address[] memory markets = new address[](1);
    markets[0] = address(cDai);
    comptroller.enterMarkets(markets);

    cBat.borrow(500);
  }

  function payback() external {
    bat.approve(address(cBat), 550);
    cBat.repayBorrow(500);
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);
  }

  

}
