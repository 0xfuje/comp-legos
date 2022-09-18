// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { CErc20TestSetup } from "./CErc20TestSetup.t.sol";

contract LiquidationTest is CErc20TestSetup {
    function testLiquidate() public {
        // MINT CWBTC
        vm.startPrank(alice);
        WBTC.approve(address(CWBTC), 10 * 1e8);
        CWBTC.mint(10 * 1e8);

        // ENTER MARKET
        address[] memory cTokens = new address[](1);
        cTokens[0] = CWBTC_ADDRESS;
        uint[] memory errs = troll.enterMarkets(cTokens);
        assertEq(errs[0], 0, "error: during call to comptroller.enterMarkets");

        // BORROW DAI
        (, uint liquidity, ) = troll.getAccountLiquidity(alice);
        uint daiPrice = priceFeed.getUnderlyingPrice(CDAI_ADDRESS);
        uint borrowAmount = (liquidity * 1e18 / daiPrice) * 9997 / 10000;
        cToken.borrow(borrowAmount);
        vm.stopPrank();

        uint borrowBalBefore = cToken.borrowBalanceCurrent(alice);
        vm.roll(block.number + 10000);
        uint borrowBalAfter = cToken.borrowBalanceCurrent(alice);

        assertGt(borrowBalAfter, borrowBalBefore, 
        "error: borrow balance after rolling block.number has to be more than before");

        // LIQUIDATOOOR
        vm.startPrank(liquidatooor);
        // 1. calculate amount to be liquidated
        uint closeFactor = troll.closeFactorMantissa();
        uint repayAmount = cToken.borrowBalanceCurrent(alice) * closeFactor;
        (uint err, uint amountToBeLiquidated) = troll.liquidateCalculateSeizeTokens(
            CDAI_ADDRESS,        // cTokenBorrowed
            CWBTC_ADDRESS,       // cTokenCollateral
            repayAmount          // actualRepayAmount
        );
        emit log_uint(closeFactor);
        emit log_uint(repayAmount);
        emit log_uint(amountToBeLiquidated);
        assertEq(err, 0);
        assertGt(amountToBeLiquidated, 0, "error: amountToBeLiquidated has to be more than 0");
        
        // 2. liquidate borrowed asset
        token.approve(address(cToken), repayAmount);
        uint errCode = cToken.liquidateBorrow(alice, repayAmount, CDAI_ADDRESS);
        assertEq(errCode, 0, "error: liquidateBorrow has failed");
    }
}