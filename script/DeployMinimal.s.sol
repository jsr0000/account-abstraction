// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";

contract DeployMinimal is Script {
    function run() public {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
