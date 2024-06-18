# Blockchain-Based Voting System

## Description

This project implements a decentralized voting system on a blockchain, designed to enhance transparency and security in voting processes. The system comprises two main components:

0. Off-chain verification system: The project require off-chain verification system, which would ensure that 1 vote = 1 voter. Project like Humanode or Civic could be used for that, or even some custom solution. After verification VotingToken would be distributed to user. Verification system is not implemented yet and for now we just assume it exists.
1. VotingToken Contract: A non-transferable ERC-721 token that represents voting rights. Each token is issued to verified voters and can be used to cast a vote.
2. VotingSystem Contract: Manages the voting process, ensuring that each vote is counted accurately and no token is used more than once.

## Features
- Decentralized Voting: Leveraging blockchain technology to ensure that the voting process is transparent and tamper-proof.
- Non-Transferable Voting Tokens: Ensures that only eligible participants can vote and that votes cannot be transferred or sold.
- Single Use Tokens: Each token can be used to cast one vote, preventing multiple votes from a single participant in a voting session.
