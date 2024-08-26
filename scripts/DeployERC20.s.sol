// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { CustomizableERC20 } from "../contracts/CustomizableERC20.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract DeployERC20 is DeployScript {
    using Strings for uint256;

    function run(string memory _name, string memory _symbol, uint8 _decimals, uint256 _maxSupply) external {
        start();

        console.log("Deploying ERC20 token...");
        console.log("  Name:", _name);
        console.log("  Symbol:", _symbol);
        console.log("  Decimals:", uint256(_decimals).toString());
        console.log("  Max Supply:", _maxSupply.toString());

        CustomizableERC20 token = new CustomizableERC20(
            _name,
            _symbol,
            _decimals,
            _maxSupply * (10 ** uint256(_decimals))
        );

        console.log(unicode"  ✓ ERC20 token deployed at:", address(token));

        end();
    }
}
