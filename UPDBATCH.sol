// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfund {
    string public title;
    address public creator;
    uint public goal;
    uint public raised;
    uint public deadline;
    mapping(address => uint) public contributions;
    bool public withdrawn;

    event ContributionReceived(address indexed contributor, uint amount);
    event FundsWithdrawn(address indexed creator, uint amount);
    event Refunded(address indexed contributor, uint amount);

    constructor(string memory _title, uint _goal, uint _durationDays) {
        title = _title;
        goal = _goal;
        creator = msg.sender;
        deadline = block.timestamp + (_durationDays * 1 days);
    }

    receive() external payable {
        contribute();
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Must send ETH");
        contributions[msg.sender] += msg.value;
        raised += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    function withdraw() public {
        require(msg.sender == creator, "Not creator");
        require(raised >= goal, "Goal not met");
        require(!withdrawn, "Already withdrawn");
        withdrawn = true;
        uint amount = address(this).balance;
        payable(creator).transfer(amount);
        emit FundsWithdrawn(creator, amount);
    }

    function refund() public {
        require(block.timestamp > deadline, "Campaign still active");
        require(raised < goal, "Goal met, no refunds");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "Nothing to refund");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributed);
        emit Refunded(msg.sender, contributed);
    }

    function getInfo() public view returns (
        string memory _title,
        address _creator,
        uint _goal,
        uint _raised,
        uint _deadline,
        bool _withdrawn
    ) {
        return (title, creator, goal, raised, deadline, withdrawn);
    }
}

contract BatchDeployCrowdfund {
    Crowdfund[] public campaigns;

    function deployAll() public {
        require(campaigns.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            string memory name = string(abi.encodePacked("Campaign", uint2str(i)));
            uint goal = i * 1 ether;
            Crowdfund c = new Crowdfund(name, goal, 10); // 10 days deadline
            campaigns.push(c);
        }
    }

    function deploySingle(string memory _title, uint _goal, uint _days) public {
        Crowdfund c = new Crowdfund(_title, _goal, _days);
        campaigns.push(c);
    }

    function get(uint index) public view returns (address) {
        return address(campaigns[index]);
    }

    function campaignsCount() public view returns (uint) {
        return campaigns.length;
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) { k--;
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        str = string(bstr);
    }
}
