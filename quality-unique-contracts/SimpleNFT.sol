
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleNFT {
    string public name = "SOM";
    string public symbol = "GSOM";
    uint256 public totalSupply;

    mapping(uint256 => address) public ownerOf;

    function mint() public {
        uint256 tokenId = totalSupply + 1;
        ownerOf[tokenId] = msg.sender;
        totalSupply++;
    }
}
