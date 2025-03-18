// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address[] private s_fundersAddress;

    mapping(address s_fundersAddress => uint256 amountFunded) private s_addressToAmountFunded;

    uint256 public constant MINIMUM_USD = 5e18;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender; // deployer of the contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversion(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        s_fundersAddress.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_fundersAddress.length;

        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_fundersAddress[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_fundersAddress = new address[](0);

          //call it been used as a transaction
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_fundersAddress.length;
            funderIndex++
        ) {
            address funder = s_fundersAddress[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_fundersAddress = new address[](0);
        // // reset the array
        // fundersAddress = new address[](0);
        // // withdraw funds

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");

        //call it been used as a transaction
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    /**
     * View / pure fuctions (Gethers)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_fundersAddress[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "mst be the owner");
        _;
    }
}
