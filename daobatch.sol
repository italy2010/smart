// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DAO {
    string public name;
    address public owner;

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }
}

contract BatchDeployDAO {
    DAO[] public daos;

    function deployAll() public {
        require(daos.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            string memory name = string(abi.encodePacked("DAO_", uint2str(i)));
            DAO dao = new DAO(name);
            daos.push(dao);
        }
    }

    function get(uint index) public view returns (address) {
        return address(daos[index]);
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
