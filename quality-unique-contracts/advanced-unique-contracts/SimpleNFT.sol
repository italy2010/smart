// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleNFT {
    string public name = "MyNFT";
    string public symbol = "MNFT";

    uint256 public totalSupply;
    mapping(uint256 => address) public ownerOf;

    function mint() public {
        totalSupply++;
        ownerOf[totalSupply] = msg.sender;
    }

    function balanceOf(address owner) public view returns (uint256) {
        uint256 count;
        for (uint256 i = 1; i <= totalSupply; i++) {
            if (ownerOf[i] == owner) count++;
        }
        return count;
    }
}
