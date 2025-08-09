// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Vote {
    string public title;
    address public creator;
    mapping(address => bool) public hasVoted;
    uint public yesVotes;
    uint public noVotes;

    constructor(string memory _title) {
        title = _title;
        creator = msg.sender;
    }

    function vote(bool _yes) public {
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;

        if (_yes) {
            yesVotes++;
        } else {
            noVotes++;
        }
    }

    function getVotes() public view returns (uint yes, uint no) {
        return (yesVotes, noVotes);
    }
}

contract Deploy30Votes {
    Vote[] public polls;

    function deployAll() public {
        require(polls.length == 0, "Already deployed");

        for (uint i = 1; i <= 30; i++) {
            string memory title = string(abi.encodePacked("Poll", uint2str(i)));
            Vote vote = new Vote(title);
            polls.push(vote);
        }
    }

    function getDeployed(uint index) public view returns (address) {
        require(index < polls.length, "Out of bounds");
        return address(polls[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k--;
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        str = string(bstr);
    }
}
