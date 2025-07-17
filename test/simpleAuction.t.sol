// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {simpleAuction} from "../src/simpleAuction.sol";

contract testSimpleAuction is Test {
    simpleAuction auction;
    address owner = address(0x1);
    address bidder = address(0x2);
    address bidder2 = address(0x3);
    uint256 expectedEndTime;

    function setUp() public {
        vm.warp(100);

        vm.prank(owner);
        auction = new simpleAuction(owner);

        vm.prank(owner);
        auction.startAuction();
    }

    function testIfOwnerIsCorrect() public view {
        assertEq(auction.owner(), owner);
    }

    function testPlaceBid() public {
        vm.deal(bidder, 5 ether);

        vm.prank(bidder);
        auction.placeBid{value: 3 ether}();

        console.log(auction.pendingReturns(bidder));

        assertEq(auction.pendingReturns(bidder), 3 ether);
    }

    function testWithdraw() public {
        vm.deal(bidder, 10 ether);
        vm.deal(bidder2, 10 ether);

        vm.prank(bidder);
        auction.placeBid{value: 5 ether}();

        vm.prank(bidder2);
        auction.placeBid{value: 7 ether}();

        vm.warp(2 days);
        vm.prank(bidder);
        auction.withdraw();
        assertEq(bidder.balance, 10 ether);
        console.log(bidder.balance);
    }

    function testEndBid() public{
        vm.deal(bidder, 10 ether);
        vm.deal(bidder2, 10 ether);

        vm.prank(bidder);
        auction.placeBid{value: 5 ether}();

        vm.prank(bidder2);
        auction.placeBid{value: 7 ether}();


        vm.warp(25 hours);
        vm.prank(bidder);
        auction.withdraw();

        uint256 balanceBefore = owner.balance;
        console.log(balanceBefore);
        vm.prank(owner);
        auction.endBid();

        uint256 balanceAfter = owner.balance;

        assertEq(balanceAfter, 7 ether);
        console.log(balanceAfter);

    }

    function testWithdrawBeforeAuctionEnds() public{ 
          vm.deal(bidder, 10 ether);
        vm.deal(bidder2, 10 ether);

        vm.prank(bidder);
        auction.placeBid{value: 5 ether}();

        vm.prank(bidder2);
        auction.placeBid{value: 7 ether}();

        vm.warp(20 hours);
        vm.prank(bidder);


        vm.expectRevert();
        auction.withdraw();
    }
}
 