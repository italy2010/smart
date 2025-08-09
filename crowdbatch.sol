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

contract BatchDeployCrowdfund {
    Crowdfund[] public campaigns;

    function deployAll() public {
        require(campaigns.length == 0, "Already deployed");

        for (uint i = 1; i <= 30; i++) {
            string memory name = string(abi.encodePacked("Campaign", uint2str(i)));
            uint goal = i * 1 ether;
            Crowdfund c = new Crowdfund(name, goal);
            campaigns.push(c);
        }
    }

    function get(uint index) public view returns (address) {
        return address(campaigns[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint j = _i; uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) { k--; bstr[k] = bytes1(uint8(48 + _i % 10)); _i /= 10; }
        str = string(bstr);
    }
}
