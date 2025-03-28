// SPDX-License-Identifier: MIT

// Fund
// withdraw

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {

    uint256 constant SEND_VALUE = 0.01 ether;
    function fundFundMe (address mostRecentlyDeploy) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeploy)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log('fund FundMe sent %s', SEND_VALUE);
    }

    function run () external {
        address mostRecentlyDeploy = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
        fundFundMe(mostRecentlyDeploy);
    }
}


contract WithdrawFundMe is Script {
    function withdrawFundMe (address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run () external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}