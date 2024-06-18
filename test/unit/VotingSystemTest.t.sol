// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {DeployVotingSystem} from "../../script/DeployVotingSystem.s.sol";
import {VotingToken} from "../../src/VotingToken.sol";
import {VotingSystem} from "../../src/VotingSystem.sol";

contract VotingSystemTest is Test {
    VotingToken votingToken;
    VotingSystem votingSystem;

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address voter1 = makeAddr("voter1");
    address voter2 = makeAddr("voter2");
    address voter3 = makeAddr("voter3");

    function setUp() public {
        DeployVotingSystem deployer = new DeployVotingSystem();
        (votingToken, votingSystem) = deployer.run();
    }

    // TEST VOTING TOKEN

    function test_issueToken() public {
        vm.prank(owner);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);
        vm.stopPrank();
    }

    function test_cantIssueTokenTwice() public {
        vm.startPrank(owner);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);
        vm.expectRevert(VotingToken.VotingToken__VoterAlreadyReceivedToken.selector);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);
        vm.stopPrank();
    }

    function test_nonOwnerCantIssueToken() public {
        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.issueToken(voter2);
        assertEq(votingToken.balanceOf(voter2), 0);
        vm.stopPrank();
    }

    function test_setVotingSystemAddress() public {
        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));
        assertEq(votingToken.s_votingSystem(), address(votingSystem));
        vm.stopPrank();
    }

    function test_burnToken() public {
        vm.prank(owner);
        votingToken.issueToken(voter2);
        assertEq(votingToken.balanceOf(voter2), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.prank(address(votingSystem));
        votingToken.burn(0);
        assertEq(votingToken.balanceOf(voter2), 0);
        vm.stopPrank();
    }

    function test_nonVotingSystemCantBurnToken() public {
        vm.prank(owner);
        votingToken.issueToken(voter3);
        assertEq(votingToken.balanceOf(voter3), 1);

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.burn(0);
        vm.stopPrank();
    }

    function test_cantBurnNonExistingToken() public {
        vm.prank(owner);
        votingToken.issueToken(voter3);
        assertEq(votingToken.balanceOf(voter3), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.prank(address(votingSystem));
        vm.expectRevert();
        votingToken.burn(1);
        assertEq(votingToken.balanceOf(voter3), 1);
        vm.stopPrank();
    }

    function test_cantTransferToken() public {
        vm.prank(owner);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.transferFrom(voter1, voter2, 0);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.safeTransferFrom(voter1, voter2, 0, "");
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.safeTransferFrom(voter1, voter2, 0);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.approve(voter2, 0);
        vm.stopPrank();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingToken.setApprovalForAll(voter2, true);
        vm.stopPrank();
    }

    // TEST VOTING SYSTEM

    function test_votingStateIsInProgress() public view {
        VotingSystem.VotingState votingState = votingSystem.getVotingState();
        assertEq(uint256(votingState), 0);
    }

    function test_vote() public {
        vm.prank(owner);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.prank(voter1);
        votingSystem.vote(0);
        assertEq(votingSystem.getVotes(0), 1);
        assertEq(votingToken.balanceOf(voter1), 0);
        vm.stopPrank();
    }

    function test_cantVoteWithoutToken() public {
        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.startPrank(voter2);
        vm.expectRevert();
        votingSystem.vote(0);
        assertEq(votingSystem.getVotes(0), 0);
        vm.stopPrank();
    }

    function test_cantVoteTwice() public {
        vm.prank(owner);
        votingToken.issueToken(voter2);
        assertEq(votingToken.balanceOf(voter2), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.prank(voter2);
        votingSystem.vote(0);
        assertEq(votingSystem.getVotes(0), 1);
        assertEq(votingToken.balanceOf(voter2), 0);

        vm.startPrank(voter2);
        vm.expectRevert();
        votingSystem.vote(0);
        assertEq(votingSystem.getVotes(0), 1);
        assertEq(votingToken.balanceOf(voter2), 0);
        vm.stopPrank();
    }

    function test_cantVoteForNonExistingOption() public {
        vm.prank(owner);
        votingToken.issueToken(voter3);
        assertEq(votingToken.balanceOf(voter3), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.prank(voter3);
        vm.expectRevert();
        votingSystem.vote(2);
        assertEq(votingSystem.getVotes(2), 0);
        assertEq(votingToken.balanceOf(voter3), 1);
        vm.stopPrank();
    }

    function test_cantVoteAfterVotingIsFinished() public {
        vm.prank(owner);
        votingToken.issueToken(voter1);
        assertEq(votingToken.balanceOf(voter1), 1);

        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.warp(block.timestamp + 1000 + 1);
        vm.roll(block.number + 1);

        vm.prank(voter1);
        votingSystem.finishVoting();

        vm.startPrank(voter1);
        vm.expectRevert();
        votingSystem.vote(0);
        assertEq(votingSystem.getVotes(0), 0);
        assertEq(votingToken.balanceOf(voter1), 1);
        vm.stopPrank();
    }

    function test_votingIsFinishedAfterDuration() public {
        vm.prank(owner);
        votingToken.setVotingSystemAddress(address(votingSystem));

        vm.warp(block.timestamp + 1000 + 1);
        vm.roll(block.number + 1);

        vm.prank(voter1);
        votingSystem.finishVoting();

        VotingSystem.VotingState votingState = votingSystem.getVotingState();
        assertEq(uint256(votingState), 1);
    }
}
