// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 private constant FUND_AMOUNT = 0.025 ether;
    uint256 private constant STARTING_BALANCE = 300 ether;
    uint256 private constant GasPrice = 1;
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //funding our default user
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        console.log(fundMe.getMinimumAmount());
        assertEq(fundMe.getMinimumAmount(), 50);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fundMe();
    }

    function testFundUpdateDataStructure() public {
        vm.prank(USER);
        fundMe.fundMe{value: FUND_AMOUNT}();

        //test for players length add array
        uint256 playersLength = fundMe.getFunders().length;
        console.log(fundMe.getFunders()[0]);
        assertEq(playersLength, 1);

        // confirm the players  amount sent so far
        uint256 playerAmountFund = fundMe.getFundersAMount(USER);
        assertEq(playerAmountFund, FUND_AMOUNT);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fundMe{value: FUND_AMOUNT}();
        _;
    }

    function testOnlyOwnerWithDraw() public funded {
        //WITHDRAW
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMutipleFunders() public funded {
        //to type cast address youd use uint160 e.g address(0) address(numberIndex)
        uint160 numberOfFUnders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFUnders; i++) {
            //THIS PRANKS AND DEAL ... hoax
            //vm.prank(user)
            // vm.deal(USER, FUND_AMOUNT)
            hoax(address(i), FUND_AMOUNT);
            fundMe.fundMe{value: FUND_AMOUNT}();
        }
        uint256 statingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingBalanceFundMe = address(fundMe).balance;

        // uint256 gasStart = gasleft();

        vm.startPrank(fundMe.getOwner());
        //tell forge to spend gas for this transaction since its default gas as zero
        // vm.txGasPrice(GasPrice);
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 totalGasUsed = (gasStart - gasEnd) * tx.gasprice;

        // console.log(totalGasUsed);

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingBalanceFundMe + statingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testcheapWithdraw() public funded {
        //to type cast address youd use uint160 e.g address(0) address(numberIndex)
        uint160 numberOfFUnders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFUnders; i++) {
            //THIS PRANKS AND DEAL ... hoax
            //vm.prank(user)
            // vm.deal(USER, FUND_AMOUNT)
            hoax(address(i), FUND_AMOUNT);
            fundMe.fundMe{value: FUND_AMOUNT}();
        }
        uint256 statingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingBalanceFundMe = address(fundMe).balance;

        // uint256 gasStart = gasleft();

        vm.startPrank(fundMe.getOwner());
        //tell forge to spend gas for this transaction since its default gas as zero
        // vm.txGasPrice(GasPrice);
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 totalGasUsed = (gasStart - gasEnd) * tx.gasprice;

        // console.log(totalGasUsed);

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingBalanceFundMe + statingOwnerBalance,
            endingOwnerBalance
        );
    }
}
