// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { CErc20 } from "../src/interfaces/CErc20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Comptroller } from "../src/interfaces/Comptroller.sol";

contract ContractTest is Test {
    IERC20 token;
    CErc20 cToken;
    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    address alice = vm.addr(1);

    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    
    function setUp() public {
        token = IERC20(DAI_ADDRESS);
        cToken = CErc20(CDAI_ADDRESS);
        deal(DAI_ADDRESS, alice, 10000 * 1e18);
    }

    function testMint() public {
        vm.startPrank(alice);
        token.approve(address(cToken), 10000 * 1e18);
        uint errCode = cToken.mint(10000 * 1e18);
        // if .mint is successfull it returns a 0
        assertEq(errCode, 0);
        emit log_uint(cToken.balanceOf(alice));
        
    }

    function testRedeem() public {
        // mint section
        vm.startPrank(alice);
        token.approve(address(cToken), 10000 * 1e18);
        cToken.mint(10000 * 1e18);

        // redeem section
        uint balUnderlying = cToken.balanceOfUnderlying(alice);
        emit log_uint(balUnderlying);

        uint cTokenAmount = cToken.balanceOf(alice);
        cToken.redeem(cTokenAmount);
        
        assertEq(token.balanceOf(alice), balUnderlying);
    }
}
