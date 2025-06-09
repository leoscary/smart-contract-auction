// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Auction {
    address public owner;
    uint public endTime;       // When the auction ends
    uint public maxEndTime;    // Max time auction can be extended to
    bool public ended;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public bids;
    address[] private biddersList;

    // Constant for max auction duration = 2 hours
    uint constant MAX_AUCTION_DURATION = 2 hours;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < endTime, "Auction ended");
        _;
    }

    constructor(uint _initialDuration) {
        require(_initialDuration <= MAX_AUCTION_DURATION, "Initial duration exceeds 2 hours");
        owner = msg.sender;
        endTime = block.timestamp + _initialDuration;
        maxEndTime = block.timestamp + MAX_AUCTION_DURATION;
    }

    function bid() external payable auctionActive {
        uint minBid = highestBid == 0 ? 1 wei : highestBid + (highestBid * 5 / 100);
        require(msg.value >= minBid, "Bid must be at least 5% higher");

        if (bids[msg.sender] == 0) {
            biddersList.push(msg.sender);
        }

        if (bids[msg.sender] > 0) {
            uint refundAmount = bids[msg.sender];
            payable(msg.sender).transfer(refundAmount);
        }

        bids[msg.sender] = msg.value;

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
        }

        // Extend time by 10 minutes only if less than 10 minutes left,
        // but never exceeding maxEndTime (2 hours from start)
        if (endTime - block.timestamp < 10 minutes) {
            uint newEndTime = endTime + 10 minutes;
            if (newEndTime > maxEndTime) {
                endTime = maxEndTime;
            } else {
                endTime = newEndTime;
            }
        }

        emit NewBid(msg.sender, msg.value);
    }

    function auctionEnd() external {
        require(block.timestamp >= endTime, "Auction not ended yet");
        require(!ended, "auctionEnd has already been called");

        ended = true;

        // Transfer highest bid minus 2% commission to owner
        uint commission = (highestBid * 2) / 100;
        uint amountToOwner = highestBid - commission;

        payable(owner).transfer(amountToOwner);

        // Refund other bidders (except winner)
        for (uint i = 0; i < biddersList.length; i++) {
            address bidder = biddersList[i];
            if (bidder != highestBidder) {
                uint refund = bids[bidder];
                if (refund > 0) {
                    bids[bidder] = 0;
                    payable(bidder).transfer(refund);
                }
            }
        }

        emit AuctionEnded(highestBidder, highestBid);
    }
}
