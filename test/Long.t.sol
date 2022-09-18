// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { CErc20TestSetup } from "./CErc20TestSetup.t.sol";

contract LongTest is CErc20TestSetup {
    function testLongETH() public {
        vm.startPrank(alice);

        // 1. enter market to enable borrow
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(CETH);
        uint[] memory errs = troll.enterMarkets(cTokens);
        assertEq(errs[0], 0, "error: call to comptroller.enterMarkets failed");

        // 2. supply ETH to compound
        CETH.mint{value: 10 * 1e18}();

        // 3. calculate how much DAI to borrow
        (uint err, uint liquidity, uint shortfall) = troll.getAccountLiquidity(
            alice
        );
        assertEq(err, 0, "error: call to comptroller.getAccountLiquidity failed");
        assertGt(liquidity, 0, "error: no borrowable liquidity");
        assertEq(shortfall, 0, "error: you are borrowed over limit");

        uint borrowPrice = priceFeed.getUnderlyingPrice(address(cToken));
        uint maxBorrow = (liquidity * 10 * 1e18) / borrowPrice;
        uint borrowAmount = (maxBorrow * 50) / 100; 

        // 4. borrow dai
        uint errCode = cToken.borrow(borrowAmount);
        assertEq(errCode, 0, "error: call to cToken.borrow failed");

        // 5. buy ETH on uniswap
        uint bal = token.balanceOf(address(this));
        token.approve(address(uniswapRouter), bal);

        address[] memory pathBuy = new address[](2);
        pathBuy[0] = address(cToken);
        pathBuy[1] = address(WETH);
        uniswapRouter.swapExactTokensForETH(
            bal,
            1,
            pathBuy,
            alice,
            block.timestamp
        );

        
        // 6. sell ETH (if price has gone up)
        address[] memory pathSell = new address[](2);
        pathSell[0] = address(WETH);
        pathSell[1] = address(cToken);
        uniswapRouter.swapExactETHForTokens{value: alice.balance}(
            1, pathSell, alice, block.timestamp
        );

        // 7. repay borrow
        uint borrowedAmount = cToken.borrowBalanceCurrent(alice);
        token.approve(address(cToken), borrowedAmount);
        uint errCodeRepay = cToken.repayBorrow(borrowedAmount);
        assertEq(errCodeRepay, 0, "error: call to cToken.repayBorrow failed");

        uint suppliedAmount = CETH.balanceOfUnderlying(alice);
        uint errCodeRedeem = CETH.redeemUnderlying(suppliedAmount);
        assertEq(errCodeRedeem, 0, "error: call to CETH.redeemUnderlying failed");

        // supplied ETH + supplied interest + profit (in token borrow);
    }

}