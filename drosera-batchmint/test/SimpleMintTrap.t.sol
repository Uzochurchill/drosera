// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SimpleMintTrapV2.sol"; // adjust path if your file name/location differs

contract MockBatchMintNFT {
    uint256 public nextTokenId;

    function mint(uint256 amount) external {
        nextTokenId += amount;
    }
}

contract SimpleMintTrapTestV2 is Test {
    SimpleMintTrapV2 trap;
    MockBatchMintNFT nft;

    function setUp() public {
        nft = new MockBatchMintNFT();
        trap = new SimpleMintTrapV2(address(nft));
    }

    /// Trigger case: create three samples with two consecutive big deltas
    function testDetectsSustainedMintBurst() public {
        // sample 0: initial counter = 0
        bytes memory s0 = abi.encode(nft.nextTokenId()); // 0

        // simulate block 1: mint 6 (delta = 6; > MAX_MINTS_PER_BLOCK which is 5)
        nft.mint(6);
        bytes memory s1 = abi.encode(nft.nextTokenId()); // 6

        // simulate block 2: mint 6 again (delta = 6; second consecutive violation)
        nft.mint(6);
        bytes memory s2 = abi.encode(nft.nextTokenId()); // 12

        // ✅ Declare samples as a bytes array with length WINDOW_SIZE
        bytes ;

        samples[0] = s0;
        samples[1] = s1;
        samples[2] = s2;

        (bool shouldRespond, bytes memory msgData) = trap.shouldRespond(samples);

        assertTrue(shouldRespond, "Trap should trigger for sustained burst");
        assertEq(abi.decode(msgData, (string)), "Sustained mint burst detected");
    }

    /// Non-trigger case: small deltas that should not create a sustained violation
    function testDoesNotTriggerForSmallMints() public {
        // sample 0: initial counter = 0
        bytes memory s0 = abi.encode(nft.nextTokenId()); // 0

        // block 1: small mint (3)
        nft.mint(3);
        bytes memory s1 = abi.encode(nft.nextTokenId()); // 3

        // block 2: small mint (2) => delta 2 (not > MAX_MINTS_PER_BLOCK)
        nft.mint(2);
        bytes memory s2 = abi.encode(nft.nextTokenId()); // 5

        // ✅ Declare samples array
        bytes ;

        samples[0] = s0;
        samples[1] = s1;
        samples[2] = s2;

        (bool shouldRespond, ) = trap.shouldRespond(samples);

        assertFalse(shouldRespond, "Trap should not trigger for small/normal minting");
    }
}
