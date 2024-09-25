// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {TokenOne} from "../src/TokenOne.sol";
import {TokenTwo} from "../src/TokenTwo.sol";
import {Exchange} from "../src/Exchange.sol";
import {console} from "forge-std/console.sol";

contract ExchangeTester is Test {
    TokenOne public tokenOne;
    TokenTwo public tokenTwo;
    Exchange public exchange;

    function setUp() public {
        vm.prank(vm.addr(420));

        tokenOne = new TokenOne();
        tokenTwo = new TokenTwo();
        exchange = new Exchange();
    }

    function test_add_liquidity() public {
        address addr1 = vm.addr(420);

        deal(addr1, 100 ether);
        deal(address(tokenOne), addr1, 50000 * 10 ** 18);
        deal(address(tokenTwo), addr1, 50000 * 10 ** 18);

        console.log(address(addr1).balance);

        vm.prank(addr1);

        tokenOne.approve(address(exchange), 10000 * 10 ** 18);
        tokenTwo.approve(address(exchange), 20000 * 10 ** 18);

        exchange.addLiquidity{value: 1 ether}(address(tokenOne), 2000);
        exchange.addLiquidity{value: 4 ether}(address(tokenTwo), 12000);

        assertEq(tokenOne.balanceOf(address(exchange)), 2000);
        assertEq(tokenTwo.balanceOf(address(exchange)), 12000);
    }
}