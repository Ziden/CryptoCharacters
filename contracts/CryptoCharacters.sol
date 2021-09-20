pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { NFTAuction } from "./NFTAuction.sol";

contract CryptoCharacters is ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  bool started = false;
  NFTAuction public auction;
  uint buyoutPrice;

  event AuctionEvent(uint256 tokenId);

  constructor() ERC721("CCharacters", "CCHRS") {
    buyoutPrice = 0.1 ether; // initial buyout. 
    NextAutoAuction();
  }

  function NextAutoAuction() private {
    _tokenIds.increment();
    if(started && auction.price() >= buyoutPrice) {
      buyoutPrice = buyoutPrice * 2;
    }
    auction = new NFTAuction(0, _tokenIds.current(), block.timestamp + 1 days, buyoutPrice);
    emit AuctionEvent(_tokenIds.current());
    started = true;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function checkAuction() public {
     if(auction.isOver()) {
      auction.finalize();
      _mint(auction.winner(), auction.tokenId());
      NextAutoAuction();
    } 
  }

  function bid() public payable {
    console.log("Super Bidding from", msg.sender);
    checkAuction();
    auction.bid(msg.sender, msg.value);
  }

  function refund() public {
    checkAuction();
    auction.refund(msg.sender);
  }
}