// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./PriceConverter.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__MinimumAmountLess();
error FundMe__notOwner();
error FundMe__transferFailed();

contract FundMe {
    //fund
    //withdraw
    //minimum fund Amount 50doll

    mapping(address => uint) private s_AddressToAMount;
    address[] private s_Funders;

    event meFund(address indexed sender, uint256 indexed price);
    event withdrawal(address indexed Withdrawal, uint256 indexed withdrawPrice);

    uint256 private constant MINIMUM_AMOUNT = 50;
    using PriceConverter for uint256;
    address private immutable i_owner;
    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
    }

    function fundMe() external payable {
        if (msg.value.getConversionRate(priceFeed) < MINIMUM_AMOUNT) {
            revert FundMe__MinimumAmountLess();
        }
        s_Funders.push(msg.sender);
        s_AddressToAMount[msg.sender] += msg.value;
        emit meFund(msg.sender, msg.value);
    }

    function cheaperWithdraw() external {
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }
        // address[] memory cheapFunder = s_Funders;
        uint256 funderLength = getFundersLength();
        for (uint i = 0; i < funderLength; i++) {
            delete (s_AddressToAMount[s_Funders[i]]);
        }
        s_Funders = new address[](0);
        (bool sucess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!sucess) {
            revert FundMe__transferFailed();
        }

        emit withdrawal(msg.sender, address(this).balance);
    }

    function withdraw() external {
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }
        // address[] memory cheapFunder = s_Funders;
        for (uint i = 0; i < s_Funders.length; i++) {
            delete (s_AddressToAMount[s_Funders[i]]);
        }
        s_Funders = new address[](0);
        (bool sucess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!sucess) {
            revert FundMe__transferFailed();
        }

        emit withdrawal(msg.sender, address(this).balance);
    }

    //getters funtion view and pure

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getVersion() external view returns (uint256) {
        return priceFeed.version();
    }

    function getAnswer() external view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function getFundersAMount(address _funders) public view returns (uint256) {
        return s_AddressToAMount[_funders];
    }

    function getFunders() public view returns (address[] memory) {
        return s_Funders;
    }

    function getMinimumAmount() public pure returns (uint256) {
        return MINIMUM_AMOUNT;
    }

    function getFundersLength() public view returns (uint256) {
        return s_Funders.length;
    }
}
