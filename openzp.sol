// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


import "@openzeppelin/contracts@4.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.0.0/access/Ownable.sol";


contract MyToken is ERC20, ERC20Burnable, Ownable {
    constructor(address initialOwner)
        ERC20("MyToken", "MTK")
        Ownable()
    {}


    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}