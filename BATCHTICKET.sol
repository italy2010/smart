// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* ===============================
   EVENT TICKET LOGIC (Implementation)
   =============================== */
contract EventTicketLogic {
    // Storage layout must match proxy
    string public eventName;
    uint public maxTickets;
    uint public sold;
    uint public ticketPrice;
    uint public eventStartTime;
    bool public salesPaused;
    address public organizer;
    mapping(address => uint) public tickets;

    /* ====== EVENTS ====== */
    event TicketsBought(address indexed buyer, uint quantity);
    event TicketsRefunded(address indexed user, uint quantity);
    event PriceChanged(uint oldPrice, uint newPrice);
    event EventTimeChanged(uint oldTime, uint newTime);
    event OrganizerChanged(address oldOrganizer, address newOrganizer);
    event SalesPaused(bool paused);
    event FundsWithdrawn(address indexed organizer, uint amount);

    /* ====== INITIALIZER ====== */
    function initialize(
        string memory _eventName,
        uint _maxTickets,
        uint _ticketPrice,
        uint _eventStartTime,
        address _organizer
    ) public {
        require(organizer == address(0), "Already initialized");
        require(_eventStartTime > block.timestamp, "Start time must be future");
        eventName = _eventName;
        maxTickets = _maxTickets;
        ticketPrice = _ticketPrice;
        eventStartTime = _eventStartTime;
        organizer = _organizer;
        salesPaused = false;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    modifier beforeEvent() {
        require(block.timestamp < eventStartTime, "Event already started");
        _;
    }

    /* ====== TICKET FUNCTIONS ====== */
    function buy(uint quantity) public payable beforeEvent {
        require(!salesPaused, "Sales paused");
        require(sold + quantity <= maxTickets, "Not enough tickets");
        require(msg.value >= quantity * ticketPrice, "Insufficient payment");

        tickets[msg.sender] += quantity;
        sold += quantity;
        emit TicketsBought(msg.sender, quantity);
    }

    function refund(uint quantity) public beforeEvent {
        require(tickets[msg.sender] >= quantity, "Not enough tickets");

        tickets[msg.sender] -= quantity;
        sold -= quantity;
        uint refundAmount = quantity * ticketPrice;
        payable(msg.sender).transfer(refundAmount);

        emit TicketsRefunded(msg.sender, quantity);
    }

    /* ====== MANAGEMENT ====== */
    function changePrice(uint newPrice) public onlyOrganizer beforeEvent {
        require(newPrice > 0, "Price must be positive");
        emit PriceChanged(ticketPrice, newPrice);
        ticketPrice = newPrice;
    }

    function changeStartTime(uint newTime) public onlyOrganizer beforeEvent {
        require(newTime > block.timestamp, "Time must be future");
        emit EventTimeChanged(eventStartTime, newTime);
        eventStartTime = newTime;
    }

    function pauseSales(bool _paused) public onlyOrganizer {
        salesPaused = _paused;
        emit SalesPaused(_paused);
    }

    function changeOrganizer(address newOrganizer) public onlyOrganizer {
        require(newOrganizer != address(0), "Invalid address");
        emit OrganizerChanged(organizer, newOrganizer);
        organizer = newOrganizer;
    }

    function withdrawAll() public onlyOrganizer {
        uint amount = address(this).balance;
        payable(organizer).transfer(amount);
        emit FundsWithdrawn(organizer, amount);
    }

    /* ====== VIEW ====== */
    function ticketsOf(address user) public view returns (uint) {
        return tickets[user];
    }

    function getEventInfo() public view returns (
        string memory name,
        uint price,
        uint available,
        uint soldTickets,
        uint startTime,
        address org,
        bool paused
    ) {
        return (
            eventName,
            ticketPrice,
            maxTickets - sold,
            sold,
            eventStartTime,
            organizer,
            salesPaused
        );
    }
}

/* ===============================
   EVENT TICKET PROXY
   =============================== */
contract EventTicketProxy {
    address public logic;
    address public admin;

    constructor(address _logic, bytes memory _data) {
        logic = _logic;
        admin = msg.sender;
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    function upgradeTo(address newLogic) public {
        require(msg.sender == admin, "Only admin");
        logic = newLogic;
    }

    fallback() external payable {
        address impl = logic;
        require(impl != address(0), "Logic not set");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

/* ===============================
   DEPLOYER FOR MULTIPLE EVENTS
   =============================== */
contract DeployEvents {
    address public owner;
    EventTicketProxy[] public events;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function deployEvent(
        address logic,
        string memory _name,
        uint _maxTickets,
        uint _price,
        uint _startTime
    ) public onlyOwner {
        bytes memory initData = abi.encodeWithSignature(
            "initialize(string,uint256,uint256,uint256,address)",
            _name,
            _maxTickets,
            _price,
            _startTime,
            owner
        );
        EventTicketProxy proxy = new EventTicketProxy(logic, initData);
        events.push(proxy);
    }

    function getEvent(uint index) public view returns (address) {
        require(index < events.length, "Out of bounds");
        return address(events[index]);
    }

    function totalEvents() public view returns (uint) {
        return events.length;
    }
}
