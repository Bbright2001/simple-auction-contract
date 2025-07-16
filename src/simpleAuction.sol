//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

//what should this contracts do??
// 1. allow users to place bid for an item
// 2. bids can only be placed before bidding ends
// 3. only the highest bid can claim the item
// 4. bidding ends after a fixed time

contract simpleAuction is Ownable{

    uint256 public highestBid = 0;
    address public highestbidder;
    uint256 public endTime;
    uint256 public constant BID_PERIOD = 24 hours; 

    mapping( address => uint256) public pendingReturns;
    

    event bidPlaced(address bidder, uint256 bid);
    event winner(address bidder);

    error bidEnded();
    error invalidBid();
    error invalidWithdrawBalance();
    error transferFailed();
    error BidNotEnded();


    constructor(address initialOwner)
    Ownable( initialOwner) {
        _transferOwnership(initialOwner);
       highestbidder = address(0);
    }

    function startAuction() external onlyOwner {
        endTime = block.timestamp + BID_PERIOD;
    }

    function placeBid() external  payable {
        if (block.timestamp > endTime) revert bidEnded();
        if (msg.value < highestBid) revert invalidBid();

        pendingReturns[highestbidder] = msg.value;

        //update state
        highestBid = msg.value;
        highestbidder = msg.sender;
    }

    function withdraw() external {
       uint256 bidAmount = pendingReturns[msg.sender];
        if (bidAmount < 0) revert invalidWithdrawBalance();

        pendingReturns[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: bidAmount}("");
        if(!(success)) revert transferFailed();
        }

    function endBid() external onlyOwner {
      if(!(block.timestamp >= endTime)) revert BidNotEnded() ; 
      

        (bool success, ) = msg.sender.call{value:highestBid}("");
        if(!(success)) revert transferFailed();
    }

}
