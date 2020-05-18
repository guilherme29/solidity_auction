//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

contract Auction {
    address payable public seller;
    string public product;
    string public details;
    uint public startingBid;
    
    bool public available;
    address bestBuyer;
    uint bestBuyerBid;
    
    mapping(address => uint) bidMap;
    address payable[] bidders;
    uint[] bids;
    
    
    constructor(address payable _seller, string memory _product, string memory _details, uint _startingBid) public {
        seller = _seller;
        product = _product;
        details = _details;
        startingBid = _startingBid;
        available = true;
    }
    
    function sell() public onlySeller() returns(address){
        //selling
        seller.transfer(bestBuyerBid);
        
        //releasing the funds
        for(uint i = 0; i < bids.length; i++){
            if(bidders[i] != bestBuyer){
                bidders[i].transfer( bids[i]);
            }
            //bids[i] = 0;
        }
        available = false;
        return bestBuyer;
    }
    
    function bid() payable public{
        require(available, "This auction is no longer available.");
        require(msg.sender != seller, "The seller may not bid in his own auction.");
        require(msg.value >= startingBid, "The bid is lower than the starting bid.");
        
        //updating best bid
        bids.push(msg.value);
        bidders.push(msg.sender);
        if(bestBuyerBid < msg.value){
            bestBuyerBid = msg.value;
            bestBuyer = msg.sender;
        }
        //adding to the bid map
        bidMap[msg.sender] = msg.value;
        
    }
    
    function myBid() public view returns(uint){
        require(msg.sender != seller, "The seller may not bid in his own auction.");
        return bidMap[msg.sender];
    }
    
    function getBestBid() public onlySeller() view returns(uint){
        uint bestSoFar = startingBid;
        for(uint i=0; i<bids.length; i++){
            if(bids[i] > bestSoFar){
                bestSoFar = bids[i];
            }
        }
        return bestSoFar;
    }
    
    function getBestBidder() public onlySeller() view returns(address) {
        uint bestSoFar = startingBid;
        uint i = 0;
        for( ; i<bids.length; i++){
            if(bids[i] > bestSoFar){
                bestSoFar = bids[i];
            }
        }
        return bidders[i];
    }
    
    modifier onlySeller(){
        require(msg.sender == seller, "Only the seller may use this function.");
        _;
    }

    
}
