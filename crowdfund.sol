// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfund {
    string public title;
    address public creator;
    uint public goal;
    uint public raised;

    constructor(string memory _title, uint _goal) {
        title = _title;
        goal = _goal;
        creator = msg.sender;
    }

    receive() external payable {
        raised += msg.value;
    }

    function withdraw() public {
        require(msg.sender == creator, "Not creator");
        require(raised >= goal, "Goal not met");
        payable(creator).transfer(address(this).balance);
    }
}
