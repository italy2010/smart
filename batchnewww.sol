// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Subscription {
    uint public price;
    address public owner;
    mapping(address => bool) public subscribers;
    uint public totalSubscribers;

    event PriceUpdated(uint oldPrice, uint newPrice);
    event Subscribed(address indexed user, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);

    constructor(uint _price) {
        price = _price;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // Update subscription price
    function updatePrice(uint _newPrice) public onlyOwner {
        uint old = price;
        price = _newPrice;
        emit PriceUpdated(old, _newPrice);
    }

    // Subscribe by paying the price
    function subscribe() public payable {
        require(msg.value == price, "Incorrect payment amount");
        require(!subscribers[msg.sender], "Already subscribed");

        subscribers[msg.sender] = true;
        totalSubscribers++;
        emit Subscribed(msg.sender, msg.value);
    }

    // Withdraw collected funds
    function withdrawFunds() public onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "No funds");
        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }
}

contract BatchDeploySubscriptions {
    Subscription[] public services;
    address public owner;

    event ServiceDeployed(address serviceAddress, uint price);
    event PriceUpdated(uint index, uint oldPrice, uint newPrice);
    event PaymentForwarded(uint index, address payer, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Deploy initial batch of subscriptions
    function deployAll() public onlyOwner {
        require(services.length == 0, "Already deployed");
        for (uint i = 1; i <= 120; i++) {
            Subscription s = new Subscription(0.01 ether);
            services.push(s);
            emit ServiceDeployed(address(s), 0.01 ether);
        }
    }

    // Deploy additional subscriptions later
    function deployMore(uint count, uint _price) public onlyOwner {
        for (uint i = 0; i < count; i++) {
            Subscription s = new Subscription(_price);
            services.push(s);
            emit ServiceDeployed(address(s), _price);
        }
    }

    // Update price for a specific subscription
    function updateSubscriptionPrice(uint index, uint _newPrice) public onlyOwner {
        require(index < services.length, "Invalid index");
        Subscription s = services[index];
        uint old = s.price();
        s.updatePrice(_newPrice);
        emit PriceUpdated(index, old, _newPrice);
    }

    // Forward payment to a subscription
    function payForSubscription(uint index) public payable {
        require(index < services.length, "Invalid index");
        Subscription s = services[index];
        require(msg.value == s.price(), "Incorrect payment amount");

        // Forward ETH
        (bool sent, ) = payable(address(s)).call{value: msg.value}("");
        require(sent, "Payment failed");

        emit PaymentForwarded(index, msg.sender, msg.value);
    }

    // Get address of a subscription
    function get(uint index) public view returns (address) {
        require(index < services.length, "Invalid index");
        return address(services[index]);
    }

    // Get total deployed services
    function totalServices() public view returns (uint) {
        return services.length;
    }

    // Get multiple addresses at once
    function getBatch(uint start, uint end) public view returns (address[] memory) {
        require(start < end && end <= services.length, "Invalid range");
        address[] memory batch = new address[](end - start);
        for (uint i = start; i < end; i++) {
            batch[i - start] = address(services[i]);
        }
        return batch;
    }
}
