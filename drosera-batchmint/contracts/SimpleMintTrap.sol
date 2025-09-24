
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ITrap } from "drosera-contracts/ITrap.sol";
import { TrapResponse } from "drosera-contracts/TrapResponse.sol";

/// @title SimpleMintTrap
/// @notice Example trap that detects too many mint events in one block and responds
contract SimpleMintTrap is ITrap {
    uint256 public constant MAX_MINTS_PER_BLOCK = 5;
    mapping(uint256 => uint256) private mintCountPerBlock;

    event TrapTriggered(address indexed offender, uint256 blockNumber, uint256 count);

    /// @notice Handles logs and returns a response if threshold is exceeded
    function handleLog(address offender, bytes calldata) external override returns (TrapResponse memory) {
        uint256 blockNumber = block.number;
        mintCountPerBlock[blockNumber]++;

        if (mintCountPerBlock[blockNumber] > MAX_MINTS_PER_BLOCK) {
            emit TrapTriggered(offender, blockNumber, mintCountPerBlock[blockNumber]);
            return TrapResponse({
                shouldRevert: true,
                message: "Too many mints in one block"
            });
        }

        return TrapResponse({
            shouldRevert: false,
            message: "OK"
        });
    }
}
