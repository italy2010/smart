// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EventTicket {
    string public eventName;
    uint public maxTickets;
    uint public sold;
    address public organizer;

    mapping(address => uint) public tickets;

    constructor(string memory _eventName, uint _maxTickets) {
        eventName = _eventName;
        maxTickets = _maxTickets;
        organizer = msg.sender;
    }

    function buy(uint quantity) public payable {
        require(sold + quantity <= maxTickets, "Not enough tickets");
        require(msg.value >= quantity * 0.01 ether, "Insufficient payment");

        tickets[msg.sender] += quantity;
        sold += quantity;
    }

    function ticketsOf(address user) public view returns (uint) {
        return tickets[user];
    }

    function withdraw() public {
        require(msg.sender == organizer, "Only organizer");
        payable(organizer).transfer(address(this).balance);
    }
}

contract Deploy30Events {
    EventTicket[] public events;

    function deployAll() public {
        require(events.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            string memory eventName = string(abi.encodePacked("Event", uint2str(i)));
            EventTicket ticket = new EventTicket(eventName, i * 10);
            events.push(ticket);
        }
    }

    function getDeployed(uint index) public view returns (address) {
        require(index < events.length, "Out of bounds");
        return address(events[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k--;
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        str = string(bstr);
    }
}
