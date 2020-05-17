//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "Auction.sol";

contract AuctionFactory {
    Auction[] auctions;
    
    function createAuction(string calldata _product, string calldata _details, uint _startingBid) external returns(address){
        Auction auction = new Auction(msg.sender, _product, _details, _startingBid);
        return address(auction);
    }
}

