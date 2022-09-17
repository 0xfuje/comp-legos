// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { CErc20 } from "../src/interfaces/CErc20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Comptroller } from "../src/interfaces/Comptroller.sol";
import { PriceFeed } from "../src/interfaces/PriceFeed.sol";

contract BaseCErc20Test is Test {
    IERC20 token;
    CErc20 cToken;
    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    PriceFeed priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    address alice = vm.addr(1);

    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    address constant WBTC_ADDRESS = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant CWBTC_ADDRESS = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a;
    
    function setUp() public {
        token = IERC20(DAI_ADDRESS);
        cToken = CErc20(CDAI_ADDRESS);
        deal(DAI_ADDRESS, alice, 10000 * 1e18);
        deal(WBTC_ADDRESS, alice, 10 * 1e8);
    }
}

contract MintAndRedeemTest is BaseCErc20Test {
    function testMint() public {
        vm.startPrank(alice);
        token.approve(address(cToken), 10000 * 1e18);
        uint errCode = cToken.mint(10000 * 1e18);
        // if .mint is successfull it returns a 0
        assertEq(errCode, 0);
        emit log_uint(cToken.balanceOf(alice));
    }

    function testRedeem() public {
        // MINT CDAI
        vm.startPrank(alice);
        token.approve(address(cToken), 10000 * 1e18);
        cToken.mint(10000 * 1e18);

        // REDEEM DAI
        uint balUnderlying = cToken.balanceOfUnderlying(alice);

        uint cTokenAmount = cToken.balanceOf(alice);

        cToken.redeem(cTokenAmount);
        assertEq(token.balanceOf(alice), balUnderlying);
    }

    function testRedeemWithInterest() public {
        // MINT CDAI
        vm.startPrank(alice);
        token.approve(address(cToken), 10000 * 1e18);
        cToken.mint(10000 * 1e18);

        // REDEEM DAI
        uint balUnderlying = cToken.balanceOfUnderlying(alice);

        vm.roll(block.number + 1000);

        uint balUnderlyingWithInterest = cToken.balanceOfUnderlying(alice);
        uint cTokenAmount = cToken.balanceOf(alice);
        
        emit log_uint(balUnderlying);
        emit log_uint(balUnderlyingWithInterest);
        assertGt(balUnderlyingWithInterest, balUnderlying);

        cToken.redeem(cTokenAmount);
        assertEq(token.balanceOf(alice), balUnderlyingWithInterest);
    }
}

contract BorrowTest is BaseCErc20Test {
    /// @notice Borrows 50% of max borrowable amount of CWBTC
    function testBorrow() public {
        // MINT CWBTC
        vm.startPrank(alice);
        IERC20 WBTC = IERC20(WBTC_ADDRESS);
        CErc20 CWBTC = CErc20(CWBTC_ADDRESS);
        WBTC.approve(address(CWBTC), 10 * 1e8);
        CWBTC.mint(10 * 1e8);
        emit log_uint(CWBTC.balanceOf(alice));

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