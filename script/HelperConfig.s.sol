// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint256 public constant OPTIMISM_SEPOLIA_CHAIN_ID = 11155420;

    struct NetworkConfig {
        address owner;
        uint256 deployerKey;
    }

    address private constant OPTIMISM_SEPOLIA_OWNER = 0xC131297b1b4b0E76f4a465c06ced6075c15C2b83;
    address private constant DEFAULT_ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private DEFAULT_ANVIL_PRIVATE_KEY = vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY");

    constructor() {
        if (block.chainid == OPTIMISM_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getOptimismSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getOptimismSepoliaConfig() public view returns (NetworkConfig memory optimismSepoliaNetworkConfig) {
        optimismSepoliaNetworkConfig =
            NetworkConfig({owner: OPTIMISM_SEPOLIA_OWNER, deployerKey: vm.envUint("PRIVATE_KEY")});
    }

    function getOrCreateAnvilConfig() public view returns (NetworkConfig memory anvilNetworkConfig) {
        // Check to see if we set an active network config
        // if (activeNetworkConfig.deployerKey != address(0)) {
        // return activeNetworkConfig;
        // }

        anvilNetworkConfig = NetworkConfig({owner: DEFAULT_ANVIL_ADDRESS, deployerKey: DEFAULT_ANVIL_PRIVATE_KEY});
    }
}
