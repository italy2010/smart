// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Staking {
    mapping(address => uint256) public balances;
    uint256 public rewardRate = 10;

    function stake() public payable {
        require(msg.value > 0, "Stake must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function checkReward(address user) public view returns (uint256) {
        return (balances[user] * rewardRate) / 100;
    }
}
