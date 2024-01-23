// SPDX-License-Identifier: MIT

//fund scripts
//witdraw scripts

pragma solidity ^0.8.18;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DeployFundMe} from "./DeployFundMe.s.sol";
import {FundMe} from "../src/fundme.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 private constant FUND_AMOUNT = 0.25 ether;

    function run() external {
        address mostRecentDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentDeploy);
    }

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();

        FundMe(payable(mostRecentlyDeployed)).fundMe{value: FUND_AMOUNT}();
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 private constant FUND_AMOUNT = 0.25 ether;

    function run() external {
        address mostRecentDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentDeploy);
    }

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();

        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }
}
