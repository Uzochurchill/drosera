// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BatchMintNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    uint256 public constant MAX_MINT_PER_TX = 5; // Maximum 5 tokens per transaction
    
    event Mint(address indexed user, uint256 tokenId);

    constructor() ERC721("Batch Mint NFT", "BMN") Ownable(msg.sender) {}

    function batchMint(uint256 times) external {
        require(times > 0, "Times must be > 0");
        require(times <= MAX_MINT_PER_TX, "Cannot mint more than 5 tokens per transaction");

        for (uint256 i = 0; i < times; i++) {
            uint256 tokenId = ++nextTokenId;
            _safeMint(msg.sender, tokenId);
            emit Mint(msg.sender, tokenId);
        }
    }

    // Optional: Owner can still mint more than 5 if needed for special cases
    function ownerBatchMint(address to, uint256 times) external onlyOwner {
        require(times > 0, "Times must be > 0");
        require(times <= 20, "Even owner cannot mint more than 20 at once"); // Gas limit protection

        for (uint256 i = 0; i < times; i++) {
            uint256 tokenId = ++nextTokenId;
            _safeMint(to, tokenId);
            emit Mint(to, tokenId);
        }
    }
}
