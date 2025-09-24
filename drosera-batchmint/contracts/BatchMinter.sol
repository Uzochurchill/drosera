
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BatchMinter {
    address public owner;
    event Mint(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function batchMint(uint256 times) external {
        require(times > 0, "Times must be > 0");
        for (uint256 i = 0; i < times; i++) {
            emit Mint(msg.sender, i + 1);
        }
    }
}
