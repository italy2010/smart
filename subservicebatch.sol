// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Subscription {
    uint public price;

    constructor(uint _price) {
        price = _price;
    }
}

contract BatchDeploySubscriptions {
    Subscription[] public services;

    function deployAll() public {
        require(services.length == 0, "Already deployed");
        for (uint i = 1; i <= 120; i++) {
            Subscription s = new Subscription(0.01 ether);
            services.push(s);
        }
    }

    function get(uint index) public view returns (address) {
        return address(services[index]);
    }
}
