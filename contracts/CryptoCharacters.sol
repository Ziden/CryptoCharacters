// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract CryptoCharacters is ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  event RefundOutbid(address indexed to, uint256 tokenId);

  struct Bid {
    uint256 tokenID;
    address bidder;
    uint value;
    bool first;
  }

  mapping (uint256 => Bid) Auctions;
  uint256 lastBuyout;

  constructor() ERC721("CCharacters", "CCHRS") {
    lastBuyout = 0.1 ether; // initial buyout. 
    NextAutoAuction();
  }

  function NextAutoAuction() private {
    _tokenIds.increment();
    Auctions[_tokenIds.current()] = Bid(_tokenIds.current(), owner(), 0, true);
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function bid(uint256 tokenId) public payable {
      Bid storage currentBid = Auctions[_tokenIds.current()];
      require(tokenId == _tokenIds.current());
      require(currentBid.first || msg.value > currentBid.value);
      if(currentBid.value > 0) {
        payable(currentBid.bidder).transfer(currentBid.value);
        emit RefundOutbid(currentBid.bidder, _tokenIds.current());
      }
      if(tokenId == currentBid.tokenID) {
        console.log("User % bidded % on %", msg.sender, msg.value, tokenId);
        currentBid.tokenID = _tokenIds.current();
        currentBid.value = msg.value;
        currentBid.bidder = msg.sender;
        currentBid.first = false;
      }
  }

  function getCurrentTokenID() public view returns (uint256) {
    return _tokenIds.current();
  }

  function getFreeItem(address user) public onlyOwner returns (uint256) 
  {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _mint(user, newItemId);
    // _setTokenURI(newItemId, tokenURI);
    console.log("Gave freebie %", newItemId);
    return newItemId;
  }


}