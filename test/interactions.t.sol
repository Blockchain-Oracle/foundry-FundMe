// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {FundFundMe} from "../script/interactions.s.sol";

contract FundMeTest is Test {
    uint256 private constant FUND_AMOUNT = 0.025 ether;
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant GasPrice = 1;
    FundMe fundMe;
    address public constant USER = address(1);

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //funding our default user
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserFundInteractions() public {
        FundFundMe fundFundMes = new FundFundMe();

        fundFundMes.fundFundMe(address(fundMe));
        vm.stopPrank();

        address funder = fundMe.getFunders()[0];
        assertEq(funder, msg.sender);
    }
}
