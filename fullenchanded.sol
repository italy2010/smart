// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Subscription contract for a single service
contract Subscription {
    uint public price;
    address public owner;
    bool public paused;
    bool public active;

    event PriceUpdated(uint oldPrice, uint newPrice);
    event Paused(bool status);
    event Activated(bool status);

    constructor(uint _price, address _owner) {
        price = _price;
        owner = _owner;
        paused = false;
        active = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @notice Update the subscription price
    function updatePrice(uint _newPrice) external onlyOwner {
        uint oldPrice = price;
        price = _newPrice;
        emit PriceUpdated(oldPrice, _newPrice);
    }

    /// @notice Pause the subscription
    function pause() external onlyOwner {
        paused = true;
        emit Paused(true);
    }

    /// @notice Resume the subscription
    function resume() external onlyOwner {
        paused = false;
        emit Paused(false);
    }

    /// @notice Deactivate the subscription
    function deactivate() external onlyOwner {
        active = false;
        emit Activated(false);
    }

    /// @notice Reactivate the subscription
    function activate() external onlyOwner {
        active = true;
        emit Activated(true);
    }
}

/// @title Batch deployment and management of subscriptions
contract BatchDeploySubscriptions {
    address public owner;
    Subscription[] public services;
    mapping(uint => bool) public isActive;

    event ServiceDeployed(address indexed service, uint price);
    event PriceUpdated(address indexed service, uint oldPrice, uint newPrice);
    event OwnershipTransferred(address oldOwner, address newOwner);

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
            isActive[services.length - 1] = true;
            emit ServiceDeployed(address(s), _price);
        }
    }

    /// @notice Add a single service later with a custom price
    function addService(uint _price) public onlyOwner {
        Subscription s = new Subscription(_price, owner);
        services.push(s);
        isActive[services.length - 1] = true;
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

    /// @notice Pause a specific service
    function pauseService(uint index) public onlyOwner {
        require(index < services.length, "Invalid index");
        services[index].pause();
    }

    /// @notice Resume a specific service
    function resumeService(uint index) public onlyOwner {
        require(index < services.length, "Invalid index");
        services[index].resume();
    }

    /// @notice Deactivate a specific service
    function deactivateService(uint index) public onlyOwner {
        require(index < services.length, "Invalid index");
        services[index].deactivate();
        isActive[index] = false;
    }

    /// @notice Activate a specific service
    function activateService(uint index) public onlyOwner {
        require(index < services.length, "Invalid index");
        services[index].activate();
        isActive[index] = true;
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

    /// @notice Get only active service addresses
    function getActiveServices() public view returns (address[] memory) {
        uint count;
        for (uint i = 0; i < services.length; i++) {
            if (isActive[i]) count++;
        }
        address[] memory activeAddresses = new address[](count);
        uint idx;
        for (uint i = 0; i < services.length; i++) {
            if (isActive[i]) {
                activeAddresses[idx] = address(services[i]);
                idx++;
            }
        }
        return activeAddresses;
    }

    /// @notice Transfer ownership of all services
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
