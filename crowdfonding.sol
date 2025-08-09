// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfund {
    string public title;
    address public creator;
    uint public goal;
    uint public raised;
    uint public deadline;
    mapping(address => uint) public contributions;

    constructor(string memory _title, uint _goal, uint _durationDays) {
        title = _title;
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationDays * 1 days);
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Campaign ended");
        contributions[msg.sender] += msg.value;
        raised += msg.value;
    }

    function withdraw() public {
        require(msg.sender == creator, "Not creator");
        require(raised >= goal, "Goal not reached");
        payable(creator).transfer(address(this).balance);
    }

    function refund() public {
        require(block.timestamp >= deadline, "Too early");
        require(raised < goal, "Goal was met");
        uint amount = contributions[msg.sender];
        require(amount > 0, "Nothing to refund");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

contract Deploy30Crowdfund {
    Crowdfund[] public campaigns;

    function deployAll() public {
        require(campaigns.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            string memory title = string(abi.encodePacked("Project", uint2str(i)));
            Crowdfund cf = new Crowdfund(title, i * 1 ether, 7);
            campaigns.push(cf);
        }
    }

    function get(uint index) public view returns (address) {
        require(index < campaigns.length);
        return address(campaigns[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        while (_i != 0) {
            bstr[--len] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
