// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract GuessGame {
    uint private secret;

    constructor(uint _secret) {
        secret = _secret;
    }
}

contract BatchDeployGames {
    GuessGame[] public games;

    function deployAll() public {
        require(games.length == 0, "Already deployed");
        for (uint i = 1; i <= 30; i++) {
            GuessGame game = new GuessGame(i);
            games.push(game);
        }
    }

    function get(uint index) public view returns (address) {
        return address(games[index]);
    }
}
