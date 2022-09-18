// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { CErc20 } from "../src/interfaces/compound/CErc20.sol";
import { CEth } from "../src/interfaces/compound/CEth.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Comptroller } from "../src/interfaces/compound/Comptroller.sol";
import { PriceFeed } from "../src/interfaces/compound/PriceFeed.sol";
import { IUniswapV2Router } from "../src/interfaces/uniswap/Uniswap.sol";

contract CErc20TestSetup is Test {
    IERC20 token;       // DAI
    CErc20 cToken;      // CDAI
    IERC20 WBTC;
    CErc20 CWBTC;
    IERC20 WETH;
    CEth CETH;

    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    PriceFeed priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);
    IUniswapV2Router uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address alice = vm.addr(1);
    address liquidatooor = vm.addr(2);

    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    address constant WBTC_ADDRESS = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant CWBTC_ADDRESS = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a;

    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    
    function setUp() public {
        token = IERC20(DAI_ADDRESS);
        cToken = CErc20(CDAI_ADDRESS);
        WBTC = IERC20(WBTC_ADDRESS);
        CWBTC = CErc20(CWBTC_ADDRESS);
        WETH = IERC20(WETH_ADDRESS);
        CETH = CEth(CETH_ADDRESS);
        deal(DAI_ADDRESS, alice, 10000 * 1e18);
        deal(WETH_ADDRESS, alice, 10 * 1e18);
        deal(DAI_ADDRESS, liquidatooor, 5000 * 1e18);
        deal(WBTC_ADDRESS, alice, 10 * 1e8);
    }
}