// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Box.sol"; // Put Box and this in the same file on Remix or use the file explorer

contract BatchDeployBox {
    Box[] public boxes;

    event BoxDeployed(address indexed box, uint index, uint initialValue);
    event BoxUpdated(address indexed box, uint index, uint newValue);

    function deployAll() public {
        require(boxes.length == 0, "Already deployed");

        for (uint i = 1; i <= 30; i++) {
            Box box = new Box(i * 10); // Initial value = 10, 20, ..., 300
            boxes.push(box);
            emit BoxDeployed(address(box), i - 1, i * 10);
        }
    }

    function getBox(uint index) public view returns (address, uint) {
        require(index < boxes.length, "Out of bounds");
        Box box = boxes[index];
        return (address(box), box.value());
    }

    function updateAll(uint newValue) public {
        for (uint i = 0; i < boxes.length; i++) {
            boxes[i].update(newValue);
            emit BoxUpdated(address(boxes[i]), i, newValue);
        }
    }

    function updateAt(uint index, uint newValue) public {
        require(index < boxes.length, "Out of bounds");
        boxes[index].update(newValue);
        emit BoxUpdated(address(boxes[index]), index, newValue);
    }

    function totalDeployed() public view returns (uint) {
        return boxes.length;
    }
}
