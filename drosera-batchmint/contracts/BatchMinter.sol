// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BatchMintToken is ERC20, Ownable {
    event Mint(address indexed user, uint256 amount);

    constructor() ERC20("Batch Mint Token", "BMT") {}

    function batchMint(uint256 times) external {
        require(times > 0, "Times must be > 0");

        // Example: 1 token per iteration (adjust decimals as needed)
        uint256 totalAmount = times * 1e18;

        _mint(msg.sender, totalAmount);
        emit Mint(msg.sender, totalAmount);
    }
}
