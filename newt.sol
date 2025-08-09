// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Subscription contract for a single service
contract Subscription {
    uint public price;
    address public owner;

    event PriceUpdated(uint oldPrice, uint newPrice);

    constructor(uint _price, address _owner) {
        price = _price;
        owner = _owner;
    }

    /// @notice Update the subscription price (only by owner)
    function updatePrice(uint _newPrice) external {
        require(msg.sender == owner, "Not the owner");
        uint oldPrice = price;
        price = _newPrice;
        emit PriceUpdated(oldPrice, _newPrice);
    }
}

/// @title Batch deployment and management of subscriptions
contract BatchDeploySubscriptions {
    address public owner;
    Subscription[] public services;

    event ServiceDeployed(address indexed service, uint price);
    event PriceUpdated(address indexed service, uint oldPrice, uint newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Deploy multiple services at once
    function deployAll(uint _price, uint _count) public onlyOwner {
        require(_count > 0, "Count must be > 0");
        for (uint i = 0; i < _count; i++) {
            Subscription s = new Subscription(_price, owner);
            services.push(s);
            emit ServiceDeployed(address(s), _price);
        }
    }

    /// @notice Add a single service later
    function addService(uint _price) public onlyOwner {
        Subscription s = new Subscription(_price, owner);
        services.push(s);
        emit ServiceDeployed(address(s), _price);
    }

    /// @notice Update price for a specific service
    function updateServicePrice(uint index, uint _newPrice) public onlyOwner {
        require(index < services.length, "Invalid index");
        Subscription s = services[index];
        uint oldPrice = s.price();
        s.updatePrice(_newPrice);
        emit PriceUpdated(address(s), oldPrice, _newPrice);
    }

    /// @notice Get service address by index
    function get(uint index) public view returns (address) {
        return address(services[index]);
    }

    /// @notice Get all deployed services
    function getAllServices() public view returns (address[] memory) {
        address[] memory addresses = new address[](services.length);
        for (uint i = 0; i < services.length; i++) {
            addresses[i] = address(services[i]);
        }
        return addresses;
    }
}
