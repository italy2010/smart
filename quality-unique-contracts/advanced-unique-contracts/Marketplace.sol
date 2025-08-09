// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Marketplace {
    struct Item {
        string name;
        uint256 price;
        address payable seller;
        bool sold;
    }

    Item[] public items;

    function listItem(string memory _name, uint256 _price) public {
        items.push(Item(_name, _price, payable(msg.sender), false));
    }

    function buyItem(uint256 index) public payable {
        Item storage item = items[index];
        require(!item.sold, "Already sold");
        require(msg.value == item.price, "Incorrect price");

        item.seller.transfer(msg.value);
        item.sold = true;
    }
}
