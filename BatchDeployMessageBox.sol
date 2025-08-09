// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MessageBox.sol"; // or paste both contracts in one Remix file

contract BatchDeployMessageBox {
    MessageBox[] public boxes;

    event BoxDeployed(address indexed box, uint index, string message);
    event MessageUpdated(address indexed box, uint index, string newMessage);

    function deployAll() public {
        require(boxes.length == 0, "Already deployed");

        for (uint i = 1; i <= 30; i++) {
            string memory initialMessage = string(abi.encodePacked("Hello ", uint2str(i)));
            MessageBox box = new MessageBox(initialMessage);
            boxes.push(box);
            emit BoxDeployed(address(box), i - 1, initialMessage);
        }
    }

    function updateAll(string memory newMessage) public {
        for (uint i = 0; i < boxes.length; i++) {
            boxes[i].updateMessage(newMessage);
            emit MessageUpdated(address(boxes[i]), i, newMessage);
        }
    }

    function updateAt(uint index, string memory newMessage) public {
        require(index < boxes.length, "Out of bounds");
        boxes[index].updateMessage(newMessage);
        emit MessageUpdated(address(boxes[index]), index, newMessage);
    }

    function getBox(uint index) public view returns (address boxAddr, string memory msgText) {
        require(index < boxes.length, "Out of bounds");
        MessageBox box = boxes[index];
        return (address(box), box.message());
    }

    function totalDeployed() public view returns (uint) {
        return boxes.length;
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
            k--; bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        str = string(bstr);
    }
}
