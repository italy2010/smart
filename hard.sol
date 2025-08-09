// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Token {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    constructor(string memory _name, string memory _symbol, uint256 _supply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _supply;
        balances[msg.sender] = _supply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        return true;
    }
}

contract Deploy30 {
    Token[] public deployedContracts;

    function deployAll() public {
        require(deployedContracts.length == 0, "Already deployed");

        for (uint i = 1; i <= 90; i++) {
            string memory name = string(abi.encodePacked("Token", uint2str(i)));
            string memory symbol = string(abi.encodePacked("TK", uint2str(i)));
            uint256 supply = i * 1000 ether;

            Token token = new Token(name, symbol, supply);
            deployedContracts.push(token);
        }
    }

    function getDeployed(uint index) public view returns (address) {
        require(index < deployedContracts.length, "Out of bounds");
        return address(deployedContracts[index]);
    }

    function uint2str(uint _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        str = string(bstr);
    }
}
