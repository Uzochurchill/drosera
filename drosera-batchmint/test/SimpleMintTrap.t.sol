
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SimpleMintTrap.sol";
import "drosera-contracts/TrapResponse.sol";

contract SimpleMintTrapTest is Test {
    SimpleMintTrap trap;

    function setUp() public {
        trap = new SimpleMintTrap();
    }

    function testTriggerAfterTooManyMints() public {
        TrapResponse memory response;
        for (uint i = 0; i < 6; i++) {
            response = trap.handleLog(address(this), "");
        }
        assert(response.shouldRevert == true);
    }
}
