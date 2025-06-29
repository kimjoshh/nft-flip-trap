// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/NFTFlipTrap.sol";

contract DeployNFTFlipTrap is Script {
    function run() external {
        vm.startBroadcast();
        new NFTFlipTrap();
        vm.stopBroadcast();
    }
}
