
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Trap} from "@drosera/contracts/src/Trap.sol";

contract SimpleMintTrapV2 is Trap {

/// @notice Minimal interface for monitored BatchMintNFT
interface IBatchMintNFT {
    function nextTokenId() external view returns (uint256);
}

/// @notice Optional interface if target supports ERC721Enumerable
interface IERC721EnumerableLike {
    function totalSupply() external view returns (uint256);
}

/// @notice SimpleMintTrapV2 detects mint bursts over short windows with persistence
contract SimpleMintTrapV2 is ITrap {
    /// @notice Address of the NFT contract being monitored
    address public immutable target;

    /// @notice Configurable thresholds (hardcoded here; could be wired from TOML/config contract)
    uint256 constant MAX_MINTS_PER_BLOCK = 5;       // main threshold
    uint256 constant MIN_BURST_SIZE = 2;            // ignore tiny blips
    uint256 constant WINDOW_SIZE = 3;               // number of blocks to consider
    uint256 constant PERSISTENCE_REQUIRED = 2;      // consecutive violations needed

    constructor(address _target) {
        target = _target;
    }

    /// @notice Collect observable state from the target
    /// @dev Samples both nextTokenId and (if supported) totalSupply
    function collect() external view override returns (bytes memory) {
        uint256 counter = IBatchMintNFT(target).nextTokenId();

        // Try/catch for totalSupply in case target doesn’t implement ERC721Enumerable
        uint256 supply = 0;
        try IERC721EnumerableLike(target).totalSupply() returns (uint256 s) {
            supply = s;
        } catch {}

        return abi.encode(counter, supply);
    }

    /// @notice Compare recent samples to detect sustained bursts
    function shouldRespond(bytes[] calldata samples)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (samples.length < WINDOW_SIZE) {
            return (false, "");
        }

        uint256 consecutiveViolations = 0;

        // Examine last WINDOW_SIZE deltas
        for (uint256 i = samples.length - WINDOW_SIZE; i < samples.length - 1; i++) {
            (uint256 curCounter, uint256 curSupply) = abi.decode(samples[i], (uint256, uint256));
            (uint256 nextCounter, uint256 nextSupply) = abi.decode(samples[i + 1], (uint256, uint256));

            uint256 deltaCounter = nextCounter - curCounter;
            uint256 deltaSupply = 0;
            if (nextSupply > curSupply) {
                deltaSupply = nextSupply - curSupply;
            }

            // Use whichever delta is nonzero (prefers nextTokenId, falls back to totalSupply)
            uint256 delta = deltaCounter > 0 ? deltaCounter : deltaSupply;

            if (delta >= MIN_BURST_SIZE && delta > MAX_MINTS_PER_BLOCK) {
                consecutiveViolations++;
                if (consecutiveViolations >= PERSISTENCE_REQUIRED) {
                    return (true, abi.encode("Sustained mint burst detected"));
                }
            } else {
                consecutiveViolations = 0; // reset streak
            }
        }

        return (false, "");
    }
}

