// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {RedCha} from "../src/RedCha.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TestRedCha is Test {
    RedCha redcha;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");

    function setUp() public {
        vm.deal(deployer, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);

        vm.startPrank(deployer);
        redcha = new redcha();
        redcha.setFeeDestination(address(deployer));
        redcha.setProtocolFeePercent(0.07 ether);
        redcha.setSubjectFeePercent(0.04 ether);
    }

    function testBuyCore() public {
        // buys cores as the owner for free
        vm.prank(user1);
        redcha.buyCores(address(user1), 1);

        // gets crore price
        uint256 corePrice = redcha.getBuyPriceAfterFee(address(user1), 1);
        console.log("Current Cores Price:",corePrice);

        // user2 should buy with an higher price
        // this is going to revert
        vm.prank(user2);
        vm.expectRevert("Insufficient payment");
        redcha.buyCores(address(user1), 1);

        // user3 buys successfully
        vm.prank(user3);
        // gets crore price after user purchase
        corePrice += redcha.getBuyPriceAfterFee(address(user1), 1);
        console.log("Current Cores Price:",corePrice);
        redcha.buyCores{value: corePrice}(address(user1), 1);

        // user4 buys successfully
        vm.prank(user4);
        // gets crore price after user purchase
        corePrice += redcha.getBuyPriceAfterFee(address(user1), 1);
        console.log("Current Cores Price:",corePrice);
        redcha.buyCores{value: corePrice}(address(user1), 1);
    }

    function testUsersSellCores() public {
        // buys cores as the owner for free
        vm.startPrank(user1);
        redcha.buyCores(address(user1), 1);

        // gets crore price
        uint256 corePrice = redcha.getBuyPriceAfterFee(address(user1), 1);
        console.log("Current Cores Price:",corePrice);

        // gets crore price after user purchase
        corePrice += redcha.getBuyPriceAfterFee(address(user1), 15);
        console.log("Current Cores Price:",corePrice);
        redcha.buyCores{value: corePrice}(address(user1), 15);
        vm.stopPrank();

        // gets crore price after user purchase
        corePrice += redcha.getBuyPriceAfterFee(address(user1), 5);
        console.log("Current Cores Price:",corePrice);
        // user2 should buy with an higher price
        vm.prank(user2);
        redcha.buyCores{value: corePrice}(address(user1), 5);

        // gets crore price after user purchase
        corePrice += redcha.getBuyPriceAfterFee(address(user1), 2);
        console.log("Current Cores Price:",corePrice);
        vm.prank(user3);
        redcha.buyCores{value: corePrice}(address(user1), 2);

        // gets crore price after user purchase
        corePrice += redcha.getBuyPrice(address(user1), 3);
        console.log("Current Cores Price:",corePrice);
        vm.prank(user4);
        redcha.buyCores{value: corePrice}(address(user1), 3);

        // user start dumping(address(user1), 15);
        console.log("Contract Balance:",address(this).balance);
        uint256 user1TotalCore = redcha.getBalance(address(user1));
        
        uint256 userBalanceBefore = address(user1).balance;
        console.log("key Owner Balance Before:", userBalanceBefore);
        vm.prank(user1);
        redcha.sellCores(address(user1), user1TotalCore);
        // assertGt(address(user1).balance, userBalanceBefore);

        uint256 userBalanceAfter = address(user1).balance;
        console.log("key Owner Balance After:", userBalanceAfter);

        // current key price
        corePrice += redcha.getBuyPrice(address(user1), 1);
        console.log("Current Cores Price:",corePrice);

        // Users start selling
        vm.prank(user2);
        redcha.sellCores(address(user1), 5);
        corePrice += redcha.getBuyPrice(address(user1), 1);
        console.log("Current Cores Price:",corePrice);

        vm.prank(user3);
        redcha.sellCores(address(user1), 2);
        corePrice += redcha.getBuyPrice(address(user1), 1);
        console.log("Current Cores Price:",corePrice);

        vm.prank(user4);
        redcha.sellCores(address(user1), 3);
        corePrice += redcha.getBuyPrice(address(user1), 1);
        console.log("Current Cores Price:",corePrice);
    }
}
