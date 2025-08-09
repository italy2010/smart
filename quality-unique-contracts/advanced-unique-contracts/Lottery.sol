// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lottery {
    address[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value >= 0.01 ether, "Minimum 0.01 ETH");
        players.push(msg.sender);
    }

    function pickWinner() public {
        require(msg.sender == manager, "Only manager");
        uint index = uint(keccak256(abi.encodePacked(block.timestamp, players.length))) % players.length;
        payable(players[index]).transfer(address(this).balance);
        players = new address[](0);
    }
}
