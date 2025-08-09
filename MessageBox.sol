// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MessageBox {
    string public message;
    address public owner;

    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender;
    }

    function updateMessage(string memory _newMessage) public {
        require(msg.sender == owner, "Only owner can update");
        message = _newMessage;
    }
}
