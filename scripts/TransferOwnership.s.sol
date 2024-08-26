// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/ProxyAdmin.sol";

import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract TransferOwnership is DeployScript {
    function run(address _newOwner) external {
        start();

        require(_newOwner != address(0), "New owner cannot be zero address");

        // Read deployed addresses from JSON file
        address v3CoreFactoryAddress = getAddress("v3CoreFactoryAddress");
        address proxyAdminAddress = getAddress("proxyAdminAddress");

        // Ensure addresses are not zero
        require(v3CoreFactoryAddress != address(0), "V3 Core Factory address not found");
        require(proxyAdminAddress != address(0), "Proxy Admin address not found");

        // Transfer ownership of V3 Core Factory
        IUniswapV3Factory factory = IUniswapV3Factory(v3CoreFactoryAddress);
        address currentFactoryOwner = factory.owner();
        if (currentFactoryOwner != _newOwner) {
            factory.setOwner(_newOwner);
            console.log("V3 Core Factory ownership transferred from", currentFactoryOwner, "to", _newOwner);
        } else {
            console.log("V3 Core Factory already owned by", _newOwner);
        }

        // Transfer ownership of Proxy Admin
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);
        address currentProxyAdminOwner = proxyAdmin.owner();
        if (currentProxyAdminOwner != _newOwner) {
            proxyAdmin.transferOwnership(_newOwner);
            console.log("Proxy Admin ownership transferred from", currentProxyAdminOwner, "to", _newOwner);
        } else {
            console.log("Proxy Admin already owned by", _newOwner);
        }

        end();
    }
}
