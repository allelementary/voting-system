// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {VotingToken} from "./VotingToken.sol";

/**
 * @author Mikhail Antonov
 * @title VotingSystem
 * @notice Contract to manage voting process. Only owners of VotingToken (verified users) can vote.
 */
contract VotingSystem {
    error VotingSystem__NotAllowedToVote();
    error VotingSystem__WrongVotingOption();
    error VotingSystem__VotingIsFinished();
    error VotingSystem__VotingStillInProgress();

    enum VotingState {
        IN_PROGRESS,
        FINISHED
    }

    mapping(uint8 => uint256) public votes;
    address public s_votingToken;
    uint8 public s_votingOptions;
    uint256 public s_votingDuration;
    uint256 public s_votingStartedAt;
    VotingState public s_votingState;

    constructor(address votingToken, uint8 votingOptions, uint256 votingDuration) {
        s_votingToken = votingToken;
        s_votingOptions = votingOptions;
        s_votingDuration = votingDuration;
        s_votingStartedAt = block.timestamp;
        s_votingState = VotingState.IN_PROGRESS;
    }

    /**
     * @notice User's has multiple options to vote for. User has to have VotingToken to vote
     * @param votingOption number of option to vote for
     */
    function vote(uint8 votingOption) public {
        if (IERC721(s_votingToken).balanceOf(msg.sender) == 0) {
            revert VotingSystem__NotAllowedToVote();
        }
        if (votingOption >= s_votingOptions) {
            revert VotingSystem__WrongVotingOption();
        }
        if (s_votingState == VotingState.FINISHED) {
            revert VotingSystem__VotingIsFinished();
        }

        // Voting logic
        votes[votingOption]++;
        // Burn VotingToken
        VotingToken(s_votingToken).burn(VotingToken(s_votingToken).getTokenId(msg.sender));
    }

    /**
     * @notice Function to finish voting. Can be called only after voting duration is over
     */
    function finishVoting() public {
        if (block.timestamp < s_votingStartedAt + s_votingDuration) {
            revert VotingSystem__VotingStillInProgress();
        }
        s_votingState = VotingState.FINISHED;
    }

    function getVotes(uint8 votingOption) public view returns (uint256) {
        return votes[votingOption];
    }

    function getVotingState() public view returns (VotingState) {
        return s_votingState;
    }
}
