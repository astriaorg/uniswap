// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { WTIA9 } from "../contracts/WTIA9.sol";

import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract WTIA9Deposit is DeployScript {
    WTIA9 private wtia9;

    function run(uint256 _amount) external {
        start();

        address weth9Address = getAddress("weth9Address");
        require(weth9Address != address(0), "WTIA9 address not found");
        wtia9 = WTIA9(weth9Address);
        wtia9.deposit{ value: _amount }();

        uint256 balance = wtia9.balanceOf(msg.sender);
        console.log(msg.sender, "wtia9 balance:", balance);

        end();
    }
}
