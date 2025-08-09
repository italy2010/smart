// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DAO {
    string public name;
    address public owner;
    mapping(address => bool) public members;

    struct Proposal {
        string description;
        uint yesVotes;
        uint noVotes;
        bool executed;
    }

    Proposal[] public proposals;

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
        members[owner] = true;
    }

    function addMember(address member) public {
        require(msg.sender == owner, "Only owner");
        members[member] = true;
    }

    function createProposal(string memory desc) public {
        require(members[msg.sender], "Not a member");
        proposals.push(Proposal(desc, 0, 0, false));
    }

    function vote(uint index, bool support) public {
        require(members[msg.sender], "Not a member");
        Proposal storage p = proposals[index];
        require(!p.executed, "Already executed");

        if (support) p.yesVotes++;
        else p.noVotes++;
    }

    function execute(uint index) public {
        Proposal storage p = proposals[index];
        require(!p.executed, "Already done");
        require(p.yesVotes > p.noVotes, "Did not pass");

        p.executed = true;
        // Add logic to act on proposal
    }
}

contract Deploy30DAOs {
    DAO[] public daos;

    function deployAll() public {
        require(daos.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            DAO dao = new DAO(string(abi.encodePacked("DAO", uint2str(i))));
            daos.push(dao);
        }
    }

    function get(uint index) public view returns (address) {
        require(index < daos.length);
        return address(daos[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint j = _i; uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        while (_i != 0) { bstr[--len] = bytes1(uint8(48 + _i % 10)); _i /= 10; }
        return string(bstr);
    }
}
