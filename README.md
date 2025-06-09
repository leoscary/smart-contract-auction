# smart-contract-auction
 Ethereum auction smart contract project for final assignment Module II
# Auction Smart Contract

This Solidity smart contract implements a simple auction with the following features:

- Owner sets an initial auction duration (maximum 2 hours).
- Bidders place bids that must be at least 5% higher than the current highest bid.
- If a bid is placed with less than 10 minutes remaining, the auction time is extended by 10 minutes, but never exceeding the 2-hour maximum.
- The highest bidder wins and the owner receives the highest bid minus a 2% commission.
- Other bidders get their bids refunded.
- Includes events for new bids and auction end.

## Usage

- Deploy the contract providing the initial auction duration (in seconds), not exceeding 7200 seconds (2 hours).
- Call `bid()` with payable ETH to place a bid.
- Call `auctionEnd()` to finalize the auction after it ends.

## Notes

- Solidity version: ^0.8.2 <0.9.0
- Tested on Remix IDE with MetaMask connected to Sepolia testnet.
