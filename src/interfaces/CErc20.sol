// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface CErc20 {
    function balanceOf(address) external view returns (uint);

    function mint(uint) external returns (uint);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function borrow(uint) external returns (uint);

    function repayBorrow(uint) external returns (uint);

    function repayBorrowBehalf(address, uint) external returns (uint);

    function transfer(address, uint256) external returns (bool);
    
    function liquidateBorrow(
        address borrower,
        uint amount,
        address collateral
    ) external returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function getCash() external returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceCurrent(address) external returns (uint);

    function borrowRatePerBlock() external returns (uint);

    function totalSupply() external returns (uint);

    function balanceOfUnderlying(address) external returns (uint);

    function supplyRatePerBlock() external returns (uint);

    function totalReserves() external returns (uint);

    function reserveFactorMantissa() external returns (uint);
}