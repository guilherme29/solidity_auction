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
    
    mapping(address => uint) public bidMap; //TODO isto nao pode ser public (temporário)
    address payable[] bidders;
    uint[] bids;
    
    
    constructor(address payable _seller, string memory _product, string memory _details, uint _startingBid) public {
        seller = _seller;
        product = _product;
        details = _details;
        startingBid = _startingBid;
        available = true;
    }
    
    function sell() payable public onlySeller() returns(address){
        //selling
        seller.transfer(bestBuyerBid);
        
        //releasing the funds
        for(uint i = 0; i < bids.length; i++){
            if(bidders[i] != bestBuyer){
                bidders[i].transfer( bids[i]);
            }
            bids[i] = 0;
        }
        available = false;
    }
    
    function bid(uint myBid) payable public{
        
        
        if(!available){
            revert("This auction is no longer available");
        }
        if(msg.sender == seller){
            revert("The seller may not bid in his own auction.");
        }
        if(myBid < startingBid){
            revert("The bid is lower than the starting bid.");
        }
        
        //updating best bid
        bids.push(myBid);
        bidders.push(msg.sender);
        if(bestBuyerBid < msg.value){
            bestBuyerBid = myBid;
            bestBuyer = msg.sender;
        }
        //adding to the bid map
        bidMap[msg.sender] = myBid;
        
    }
    
    function myBid() public view returns(uint){
        if(msg.sender == seller){
            revert("The seller may not bid in his own auction.");
        }
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
        require(msg.sender == seller);
        _;
    }

    
}
