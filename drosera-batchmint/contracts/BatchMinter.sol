// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BatchMintNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    event Mint(address indexed user, uint256 tokenId);

    constructor() ERC721("Batch Mint NFT", "BMN") {}

    function batchMint(uint256 times) external {
        require(times > 0, "Times must be > 0");

        for (uint256 i = 0; i < times; i++) {
            uint256 tokenId = ++nextTokenId;
            _safeMint(msg.sender, tokenId);
            emit Mint(msg.sender, tokenId);
        }
    }
}
