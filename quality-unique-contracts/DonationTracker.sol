
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DonationTracker {
    mapping(address => uint256) public donations;

    event Donated(address indexed donor, uint256 amount);

    receive() external payable {
        donations[msg.sender] += msg.value;
        emit Donated(msg.sender, msg.value);
    }

    function totalDonated() public view returns (uint256) {
        return address(this).balance;
    }
}
