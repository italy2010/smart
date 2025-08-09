
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Escrow {
    address public payer;
    address public payee;
    address public lawyer;
    uint256 public amount;

    constructor(address _payer, address _payee, uint256 _amount) {
        payer = _payer;
        payee = _payee;
        lawyer = msg.sender;
        amount = _amount;
    }

    receive() external payable {}

    function release() public {
        require(msg.sender == lawyer, "Only lawyer");
        require(address(this).balance >= amount, "Insufficient balance");
        payable(payee).transfer(amount);
    }
}
