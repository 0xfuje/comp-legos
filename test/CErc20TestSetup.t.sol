// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import { CErc20 } from "../src/interfaces/CErc20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Comptroller } from "../src/interfaces/Comptroller.sol";
import { PriceFeed } from "../src/interfaces/PriceFeed.sol";

contract CErc20TestSetup is Test {
    IERC20 token;       // DAI
    CErc20 cToken;      // CDAI
    IERC20 WBTC;
    CErc20 CWBTC;
    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    PriceFeed priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    address alice = vm.addr(1);
    address liquidatooor = vm.addr(2);

    address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    address constant WBTC_ADDRESS = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant CWBTC_ADDRESS = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a;
    
    function setUp() public {
        token = IERC20(DAI_ADDRESS);
        cToken = CErc20(CDAI_ADDRESS);
        WBTC = IERC20(WBTC_ADDRESS);
        CWBTC = CErc20(CWBTC_ADDRESS);
        deal(DAI_ADDRESS, alice, 10000 * 1e18);
        deal(DAI_ADDRESS, liquidatooor, 5000 * 1e18);
        deal(WBTC_ADDRESS, alice, 10 * 1e8);
    }
}