// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {HelperConfig} from "./helper-config.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
