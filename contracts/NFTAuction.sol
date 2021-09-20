pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract NFTAuction is Ownable {
  
  uint256 public tokenId;
  uint public price;
  uint public buyout;
  bool public initialPrice = true;
  uint public timestampEnd;
  bool public finalized = false;
  bool public buyOuted = false;
  address public winner;
  mapping(address => uint) public bids;

  // Bidding on the last hour will increase the auction for an extra hour to avoid cheats
  uint public increaseTimeIfBidBeforeEnd = 60 * 60;
  uint public increaseTimeBy = 60 * 60;

  event BidEvent(address indexed bidder, uint value, uint timestamp);
  event Refund(address indexed bidder, uint value, uint timestamp);
  event Finish(address indexed bidder, uint256 tokenId, uint value);

  modifier onlyWinner { require(winner == msg.sender); _; }
  modifier ended { require( isOver()); _; }

  function isOver() public view returns(bool) {
      return block.timestamp > timestampEnd;
  }

  constructor(uint _price, uint256 _tokenID, uint _timestampEnd, uint _buyout) {
    require(_timestampEnd > block.timestamp);
    buyout = _buyout;
    price = _price;
    tokenId = _tokenID;
    timestampEnd = _timestampEnd;
  }

  function bid(address bidder, uint value) public payable {
    require(block.timestamp < timestampEnd);
    console.log("Bidding from", bidder);
    if (bids[bidder] > 0) { 
      bids[bidder] += value;
    } else {
      bids[bidder] = value;
    }
    console.log("1");
    if (initialPrice) {
      require(bids[bidder] >= price);
    } else {
      require(bids[bidder] >= (price * 5 / 4));
    }
    console.log("2");
    if (block.timestamp > timestampEnd - increaseTimeIfBidBeforeEnd) {
      timestampEnd = block.timestamp + increaseTimeBy;
    }

    initialPrice = false;
    price = bids[bidder];
    winner = bidder;
    console.log("% bid % on %", winner, price, tokenId);
    emit BidEvent(winner, value, block.timestamp);
    if(price >= buyout) {
       timestampEnd = block.timestamp;
       buyOuted = true;
       finish();
    }
  }

  function finalize() public ended() onlyOwner() {
    require(finalized == false);
    require(initialPrice == false);
    finish();
  }

  function finish() private {
    console.log("Auction finishing");
    finalized = true;
    emit Finish(winner, tokenId, price);
  }

  function refund(address addr) public { // make sure users cant call this
    require(addr != winner);
    require(bids[addr] > 0);

    uint refundValue = bids[addr];
    bids[addr] = 0;
    payable(addr).transfer(refundValue);
    console.log("Refunded % for %", addr, refundValue);
    emit Refund(addr, refundValue, block.timestamp);
  }
}