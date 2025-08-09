// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {
    address[] public owners;
    uint public requiredApprovals;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 approvals;
    }

    mapping(uint => mapping(address => bool)) public approvals;
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _requiredApprovals) {
        require(_owners.length >= _requiredApprovals);
        owners = _owners;
        requiredApprovals = _requiredApprovals;
    }

    function submit(address to, uint value) public {
        require(isOwner(msg.sender), "Not an owner");
        transactions.push(Transaction(to, value, false, 0));
    }

    function approve(uint txId) public {
        require(isOwner(msg.sender), "Not an owner");
        require(!approvals[txId][msg.sender], "Already approved");
        approvals[txId][msg.sender] = true;
        transactions[txId].approvals++;

        if (transactions[txId].approvals >= requiredApprovals) {
            execute(txId);
        }
    }

    function execute(uint txId) internal {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Already executed");
        txn.executed = true;
        payable(txn.to).transfer(txn.value);
    }

    function isOwner(address addr) internal view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == addr) return true;
        }
        return false;
    }

    receive() external payable {}
}
