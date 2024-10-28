// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { WTIA9 } from "../contracts/WTIA9.sol";

import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract DeployWTIA9 is DeployScript {
    function run(string memory _name, string memory _symbol) external {
        start();

        address weth9Address = getAddress("weth9Address");
        if (weth9Address == address(0)) {
            console.log("Deploying WETH9...");
            console.log("  Name:", _name);
            console.log("  Symbol:", _symbol);

            WTIA9 weth9 = new WTIA9(_name, _symbol);
            weth9Address = address(weth9);

            console.log(unicode"  ✓ WETH9 deployed at:", weth9Address);
            setAddress("weth9Address", weth9Address);
        } else {
            console.log(unicode"✓ WETH9 already deployed at:", weth9Address);
        }

        end();
    }
}
