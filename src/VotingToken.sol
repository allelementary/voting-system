// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @author Mikhail Antonov
 * @title VotingToken
 * @notice GovernanceToken would be provided to verified users to participate in voting. New token would be minted for each voting session.
 * Verification system would ensure there is one vote for one human. Users can't transfer tokens to each other.
 */
contract VotingToken is ERC721, Ownable, ReentrancyGuard {
    error VotingToken__NotAllowedToTransfer();
    error VotingToken__VoterAlreadyReceivedToken();

    mapping(address => bool) public s_receivedToken;
    mapping(address => uint256) public s_addressToTokenId;
    uint256 private s_currentTokenId = 0;
    address public s_votingSystem;

    event TokenIssued(uint256 tokenId, address indexed user);
    event TokenBurned(uint256 tokenId);

    constructor(address owner) Ownable(owner) ERC721("VotingToken", "VOTE") {}

    modifier onlyVotingSystem() {
        if (msg.sender != s_votingSystem) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    /**
     * @notice Issue token to user
     * @param user address of user
     * @dev Function called by off-chain verification system after user passed verification
     */
    function issueToken(address user) public onlyOwner nonReentrant {
        if (s_receivedToken[user]) {
            revert VotingToken__VoterAlreadyReceivedToken();
        }

        uint256 newTokenId = s_currentTokenId++;
        _mint(user, newTokenId);
        s_receivedToken[user] = true;
        s_addressToTokenId[user] = newTokenId;
        emit TokenIssued(newTokenId, user);
    }

    function setVotingSystemAddress(address votingSystem) public onlyOwner {
        s_votingSystem = votingSystem;
    }

    function burn(uint256 tokenId) public onlyVotingSystem {
        _burn(tokenId);
        emit TokenBurned(tokenId);
    }

    function getTokenId(address owner) public view returns (uint256) {
        return s_addressToTokenId[owner];
    }

    /**
     * DISABLE TOKEN TRANSFER FUNCTIONS
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        revert VotingToken__NotAllowedToTransfer();
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        revert VotingToken__NotAllowedToTransfer();
    }

    // function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    //     revert VotingToken__NotAllowedToTransfer();
    // }

    function approve(address to, uint256 tokenId) public override {
        revert VotingToken__NotAllowedToTransfer();
    }

    function setApprovalForAll(address operator, bool approved) public override {
        revert VotingToken__NotAllowedToTransfer();
    }
}
