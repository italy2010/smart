// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Box {
    uint public value;
    address public owner;

    constructor(uint _value) {
        value = _value;
        owner = msg.sender;
    }

    function update(uint _newValue) public {
        require(msg.sender == owner, "Only owner can update");
        value = _newValue;
    }
}
