// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdpriceFeed = helperConfig.activeNetworkConfig();

        //After startBroadcast => real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdpriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
