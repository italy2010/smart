// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Subscription {
    uint public price;
    address public owner;

    event PriceUpdated(uint oldPrice, uint newPrice);

    constructor(uint _price) {
        price = _price;
        owner = msg.sender;
    }

    function updatePrice(uint _newPrice) public {
        require(msg.sender == owner, "Only owner can update price");
        uint old = price;
        price = _newPrice;
        emit PriceUpdated(old, _newPrice);
    }
}

contract BatchDeploySubscriptions {
    Subscription[] public services;
    address public owner;

    event ServiceDeployed(address serviceAddress, uint price);
    event PriceUpdated(uint index, uint oldPrice, uint newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Deploy initial batch
    function deployAll() public onlyOwner {
        require(services.length == 0, "Already deployed");
        for (uint i = 1; i <= 120; i++) {
            Subscription s = new Subscription(0.01 ether);
            services.push(s);
            emit ServiceDeployed(address(s), 0.01 ether);
        }
    }

    // Deploy additional subscriptions any time
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

    // Get address of subscription by index
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
