// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import { UniswapV3Pool } from "@uniswap/v3-core/contracts/UniswapV3Pool.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { DeployScript } from "./DeployScript.s.sol";
import { console } from "forge-std/Script.sol";

contract DeployPool is DeployScript {
    using Strings for uint256;

    UniswapV3Factory private v3CoreFactory;
    UniswapV3Pool private v3Pool;

    function run(address _tokenA, address _tokenB, uint24 _fee, uint160 _sqrtPriceX96) external {
        start();

        console.log("Deploying Uniswap V3 Pool...");
        console.log("  Token A:", _tokenA);
        console.log("  Token B:", _tokenB);
        console.log("  Fee:", uint256(_fee).toString());
        console.log("  Initial sqrtPriceX96:", uint256(_sqrtPriceX96).toString());

        address factoryAddress = getAddress("v3CoreFactoryAddress");
        require(factoryAddress != address(0), "UniswapV3Factory address not found");
        v3CoreFactory = UniswapV3Factory(factoryAddress);

        // DEPLOY POOL
        address poolAddr = v3CoreFactory.getPool(_tokenA, _tokenB, _fee);
        if (poolAddr == address(0)) {
            console.log("Pool does not exist; creating...");

            v3CoreFactory.createPool(_tokenA, _tokenB, _fee);

            poolAddr = v3CoreFactory.getPool(_tokenA, _tokenB, _fee);

            console.log(unicode"  ✓ Created pool:", poolAddr);
        } else {
            console.log(unicode"✓ Found existing pool:", poolAddr);
        }

        // INITIALIZE POOL
        v3Pool = UniswapV3Pool(poolAddr);

        (uint160 sqrtPriceX96Check, , , , , , ) = v3Pool.slot0();

        if (sqrtPriceX96Check == 0) {
            console.log("Initializing pool with price sqrtPriceX96 =", uint256(_sqrtPriceX96).toString());
            v3Pool.initialize(_sqrtPriceX96);
            console.log(unicode"  ✓ Pool initialized");
        } else {
            console.log(
                unicode"✓ Pool already initialized. Current price sqrtPriceX96 =",
                uint256(sqrtPriceX96Check).toString()
            );
        }

        end();
    }
}
