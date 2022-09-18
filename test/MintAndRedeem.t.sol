// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { CErc20TestSetup } from "./CErc20TestSetup.t.sol";

contract MintAndRedeemTest is CErc20TestSetup {
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