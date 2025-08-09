// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Auction {
    string public item;
    address public highestBidder;
    uint public highestBid;
    uint public endTime;
    address public seller;

    constructor(string memory _item) {
        item = _item;
        seller = msg.sender;
        endTime = block.timestamp + 3 days;
    }

    function bid() public payable {
        require(block.timestamp < endTime, "Auction ended");
        require(msg.value > highestBid, "Low bid");

        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    function finalize() public {
        require(block.timestamp >= endTime, "Too early");
        require(msg.sender == seller, "Only seller");
        payable(seller).transfer(highestBid);
    }
}

contract Deploy30Auctions {
    Auction[] public auctions;

    function deployAll() public {
        require(auctions.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            Auction a = new Auction(string(abi.encodePacked("Item", uint2str(i))));
            auctions.push(a);
        }
    }

    function get(uint index) public view returns (address) {
        require(index < auctions.length);
        return address(auctions[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint j = _i; uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        while (_i != 0) { bstr[--len] = bytes1(uint8(48 + _i % 10)); _i /= 10; }
        return string(bstr);
    }
}
