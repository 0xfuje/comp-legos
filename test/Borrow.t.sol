// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { CErc20TestSetup } from "./CErc20TestSetup.t.sol";

contract BorrowTest is CErc20TestSetup {
    /// @notice Borrows 50% of max borrowable amount of CWBTC
    function testBorrow() public {
        // MINT CWBTC
        vm.startPrank(alice);
        WBTC.approve(address(CWBTC), 10 * 1e8);
        CWBTC.mint(10 * 1e8);
        
        // BORROW DAI
        // 1. call enter markets on comptroller with minted token
        address[] memory cTokens = new address[](1);
        cTokens[0] = CWBTC_ADDRESS;
        uint[] memory errs = troll.enterMarkets(cTokens);
        assertEq(errs[0], 0, "error: during call to comptroller.enterMarkets");

        // 2. check account liquidity
        (uint err, uint liquidity, uint shortfall) = troll.getAccountLiquidity(
            alice
        );
        emit log_uint(liquidity);
        assertEq(err, 0, "error: during call to comptroller.getAccountLiquidity");
        assertGt(liquidity, 0, "error: no borrowable liquidity");
        assertEq(shortfall, 0, "error: you are borrowed over limit");

        // 3. calculate maximum borowable amount
        uint priceOfBorrowToken = priceFeed.getUnderlyingPrice(CDAI_ADDRESS);
        // liquidity and price is usd amount scaled up by 1e18;
        uint decimalsDAI = 18;
        uint maxBorrowTokens = (liquidity * (10 ** decimalsDAI)) / priceOfBorrowToken;
        assertGt(maxBorrowTokens, 0, "error: borrowable has to be more than 0");

        // 4. borrow 50% of max borrow
        uint borrowAmount = (maxBorrowTokens * 50) / 100;
        uint errCode = cToken.borrow(borrowAmount);
        assertEq(errCode, 0, "error: during call to CDAI.borrow");
    }
}