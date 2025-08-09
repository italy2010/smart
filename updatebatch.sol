// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EventTicket {
    string public eventName;
    uint public maxTickets;
    uint public sold;
    uint public ticketPrice;
    address public organizer;
    address public manager; // Deploy30Events contract address

    mapping(address => uint) public tickets;

    modifier onlyOrganizerOrManager() {
        require(
            msg.sender == organizer || msg.sender == manager,
            "Not authorized"
        );
        _;
    }

    constructor(
        string memory _eventName,
        uint _maxTickets,
        uint _ticketPrice,
        address _organizer,
        address _manager
    ) {
        eventName = _eventName;
        maxTickets = _maxTickets;
        ticketPrice = _ticketPrice;
        organizer = _organizer;
        manager = _manager;
    }

    function buy(uint quantity) public payable {
        require(sold + quantity <= maxTickets, "Not enough tickets");
        require(msg.value >= quantity * ticketPrice, "Insufficient payment");

        tickets[msg.sender] += quantity;
        sold += quantity;
    }

    function ticketsOf(address user) public view returns (uint) {
        return tickets[user];
    }

    function withdraw() public onlyOrganizerOrManager {
        payable(organizer).transfer(address(this).balance);
    }

    // --- Management Functions ---
    function changeTicketPrice(uint newPrice) public onlyOrganizerOrManager {
        ticketPrice = newPrice;
    }

    function changeMaxTickets(uint newMax) public onlyOrganizerOrManager {
        require(newMax >= sold, "Cannot reduce below sold tickets");
        maxTickets = newMax;
    }
}

contract Deploy30Events {
    EventTicket[] public events;

    function deployAll() public {
        require(events.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            string memory eventName = string(abi.encodePacked("Event", uint2str(i)));
            // Set ticket price to 0.01 ether by default
            EventTicket ticket = new EventTicket(
                eventName,
                i * 10,
                0.01 ether,
                msg.sender, // organizer is the deployer of Deploy30Events
                address(this) // manager is this contract
            );
            events.push(ticket);
        }
    }

    function getDeployed(uint index) public view returns (address) {
        require(index < events.length, "Out of bounds");
        return address(events[index]);
    }

    // --- Manager control over events ---
    function managerChangePrice(uint index, uint newPrice) public {
        require(index < events.length, "Out of bounds");
        EventTicket ticket = events[index];
        ticket.changeTicketPrice(newPrice);
    }

    function managerChangeMax(uint index, uint newMax) public {
        require(index < events.length, "Out of bounds");
        EventTicket ticket = events[index];
        ticket.changeMaxTickets(newMax);
    }

    function managerWithdraw(uint index) public {
        require(index < events.length, "Out of bounds");
        EventTicket ticket = events[index];
        ticket.withdraw();
    }

    // Helper: uint to string
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
