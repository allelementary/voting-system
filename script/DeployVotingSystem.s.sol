// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VotingToken} from "../src/VotingToken.sol";
import {VotingSystem} from "../src/VotingSystem.sol";

contract DeployVotingSystem is Script {
    uint8 public constant VOTING_OPTIONS = 2;
    uint256 public constant VOTING_DURATION = 1000;

    function run() external returns (VotingToken, VotingSystem) {
        HelperConfig helperConfig = new HelperConfig();

        (address owner, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        vm.startBroadcast(deployerKey);
        VotingToken votingToken = new VotingToken(owner);

        VotingSystem votingSystem = new VotingSystem(address(votingToken), VOTING_OPTIONS, VOTING_DURATION);
        vm.stopBroadcast();

        return (votingToken, votingSystem);
    }
}
