
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    struct Task {
        string description;
        bool completed;
    }

    Task[] public tasks;

    function addTask(string memory _desc) public {
        tasks.push(Task(_desc, false));
    }

    function toggleTask(uint256 index) public {
        require(index < tasks.length, "Invalid index");
        tasks[index].completed = !tasks[index].completed;
    }
}
