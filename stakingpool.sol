// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Staking {
    address public creator;

    constructor() {
        creator = msg.sender;
    }

    function stake() public payable {}
}

contract BatchDeployStaking {
    Staking[] public pools;

    function deployAll() public {
        require(pools.length == 0, "Already deployed");
        for (uint i = 1; i <= 90; i++) {
            Staking s = new Staking();
            pools.push(s);
        }
    }

    function get(uint index) public view returns (address) {
        return address(pools[index]);
    }
}
