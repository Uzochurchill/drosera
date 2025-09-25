// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BatchMinter.sol";
import "../src/SimpleMintTrapV2.sol";

contract TrapLogicTest is Test {
    BatchMintNFT nft;
    SimpleMintTrapV2 trap;

    function setUp() public {
        nft = new BatchMintNFT();
        trap = new SimpleMintTrapV2(address(nft));
    }

    function testOriginalLogicWouldFail() public view {
        // This pattern should trigger with PERSISTENCE_REQUIRED = 2
        // But your original logic might miss it
        bytes[] memory samples = new bytes[](4);
        samples[0] = abi.encode(0, 0);   // start
        samples[1] = abi.encode(10, 10); // +10 (violation 1)
        samples[2] = abi.encode(20, 20); // +10 (violation 2) <- should trigger here
        samples[3] = abi.encode(22, 22); // +2  (normal)

        (bool shouldRespond,) = trap.shouldRespond(samples);
        assertTrue(shouldRespond, "Should detect 2 consecutive violations");
    }

    function testNormalActivity() public view {
        // Normal activity - should NOT trigger
        bytes[] memory samples = new bytes[](4);
        samples[0] = abi.encode(0, 0);
        samples[1] = abi.encode(3, 3);   // +3 mints (under threshold)
        samples[2] = abi.encode(6, 6);   // +3 mints (under threshold)
        samples[3] = abi.encode(9, 9);   // +3 mints (under threshold)

        (bool shouldRespond,) = trap.shouldRespond(samples);
        assertFalse(shouldRespond, "Should NOT trigger on normal activity");
    }

    function testSingleBurst() public view {
        // Single burst followed by normal - should NOT trigger
        bytes[] memory samples = new bytes[](4);
        samples[0] = abi.encode(0, 0);
        samples[1] = abi.encode(10, 10); // +10 (violation)
        samples[2] = abi.encode(12, 12); // +2  (normal)
        samples[3] = abi.encode(14, 14); // +2  (normal)

        (bool shouldRespond,) = trap.shouldRespond(samples);
        assertFalse(shouldRespond, "Should NOT trigger on single burst");
    }

    function testSustainedBurst() public view {
        // Sustained burst - SHOULD trigger
        bytes[] memory samples = new bytes[](4);
        samples[0] = abi.encode(0, 0);
        samples[1] = abi.encode(10, 10); // +10 (violation 1)
        samples[2] = abi.encode(20, 20); // +10 (violation 2) <- triggers here
        samples[3] = abi.encode(30, 30); // +10 (violation 3)

        (bool shouldRespond, bytes memory reason) = trap.shouldRespond(samples);
        assertTrue(shouldRespond, "Should trigger on sustained burst");
        
        string memory reasonStr = abi.decode(reason, (string));
        assertEq(reasonStr, "Sustained mint burst detected");
    }

    function testEdgeCases() public view {
        // Test minimum samples
        bytes[] memory tooFew = new bytes[](2);
        tooFew[0] = abi.encode(0, 0);
        tooFew[1] = abi.encode(100, 100);
        
        (bool shouldRespond,) = trap.shouldRespond(tooFew);
        assertFalse(shouldRespond, "Should not respond with insufficient samples");
    }

    function testBurstThenRecovery() public view {
        // Burst, then recovery - should NOT trigger (violations reset)
        bytes[] memory samples = new bytes[](5);
        samples[0] = abi.encode(0, 0);
        samples[1] = abi.encode(10, 10); // +10 (violation)
        samples[2] = abi.encode(12, 12); // +2  (normal - resets)
        samples[3] = abi.encode(22, 22); // +10 (violation - starts new streak)
        samples[4] = abi.encode(32, 32); // +10 (violation - only 1 consecutive)

        (bool shouldRespond,) = trap.shouldRespond(samples);
        assertFalse(shouldRespond, "Should not trigger when violations are interrupted");
    }

    function testConstants() public view {
        // Verify your thresholds
        assertEq(trap.MAX_MINTS_PER_BLOCK(), 5);
        assertEq(trap.MIN_BURST_SIZE(), 2);
        assertEq(trap.WINDOW_SIZE(), 3);
        assertEq(trap.PERSISTENCE_REQUIRED(), 2);
    }

    function testRealMintingLimit() public {
        address user = makeAddr("user");
        
        vm.startPrank(user);
        // ✅ This works - 5 tokens is allowed
        nft.batchMint(5);
        assertEq(nft.nextTokenId(), 5);

        // ❌ This should fail - 6 tokens is blocked
        vm.expectRevert("Cannot mint more than 5 tokens per transaction");
        nft.batchMint(6);
        vm.stopPrank();
    }

    function testOwnerCanMintMore() public {
        address user = makeAddr("user");
        
        // Owner can mint more than 5
        nft.ownerBatchMint(user, 10);
        assertEq(nft.nextTokenId(), 10);
        
        // But even owner has limits
        vm.expectRevert("Even owner cannot mint more than 20 at once");
        nft.ownerBatchMint(user, 21);
    }
}
