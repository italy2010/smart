// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DeadManSwitch {
    address public owner;
    address public beneficiary;
    uint public lastCheckin;
    uint public timeout;

    constructor(address _beneficiary, uint _timeoutSeconds) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        timeout = _timeoutSeconds;
        lastCheckin = block.timestamp;
    }

    function checkIn() public {
        require(msg.sender == owner, "Only owner");
        lastCheckin = block.timestamp;
    }

    function claim() public {
        require(block.timestamp > lastCheckin + timeout, "Not timed out");
        payable(beneficiary).transfer(address(this).balance);
    }

    receive() external payable {}
}
