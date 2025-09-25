// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SimpleMintTrap.sol";

contract MockBatchMintNFT {
    uint256 public nextTokenId;

    function mint(uint256 amount) external {
        nextTokenId += amount;
    }
}

contract SimpleMintTrapTest is Test {
    SimpleMintTrap trap;
    MockBatchMintNFT nft;

    function setUp() public {
        nft = new MockBatchMintNFT();
        trap = new SimpleMintTrap(address(nft));
    }

    function testDetectsMintBurst() public {
        // simulate previous block
        nft.mint(2);
        bytes memory prev = abi.encode(nft.nextTokenId());

        // simulate current block with too many mints
        nft.mint(10);
        bytes memory latest = abi.encode(nft.nextTokenId());

        bytes ;
        samples[0] = prev;
        samples[1] = latest;

        (bool shouldRevert, bytes memory msgData) = trap.shouldRespond(samples);

        assertTrue(shouldRevert, "Trap should trigger");
        assertEq(abi.decode(msgData, (string)), "Too many mints in one block");
    }

    function testDoesNotTriggerForSmallMints() public {
        // simulate previous block
        nft.mint(1);
        bytes memory prev = abi.encode(nft.nextTokenId());

        // simulate current block with small mint
        nft.mint(3);
        bytes memory latest = abi.encode(nft.nextTokenId());

        bytes ;
        samples[0] = prev;
        samples[1] = latest;

        (bool shouldRevert, ) = trap.shouldRespond(samples);

        assertFalse(shouldRevert, "Trap should not trigger");
    }
}
