// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { IWETH9 } from "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";

import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract WETH9Deposit is DeployScript {
    IWETH9 private weth9;

    function run(uint256 _amount) external {
        start();

        address weth9Address = getAddress("weth9Address");
        require(weth9Address != address(0), "WETH9 address not found");
        weth9 = IWETH9(weth9Address);
        weth9.deposit{ value: _amount }();

        uint256 balance = weth9.balanceOf(msg.sender);
        console.log(msg.sender, "weth9 balance:", balance);

        end();
    }
}
