// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {UniswapV3Pool} from "@uniswap/v3-core/contracts/UniswapV3Pool.sol";
import {INonfungiblePositionManager} from '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import {TransferHelper} from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import {TickMath} from '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import {IWETH9} from '@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {DeployScript} from "./DeployScript.s.sol";
import {console} from "forge-std/Script.sol";

contract CreatePosition is DeployScript {
    using Strings for uint256;

    UniswapV3Factory private v3CoreFactory;
    UniswapV3Pool private v3Pool;
    INonfungiblePositionManager private nonfungiblePositionManager;

    function run(
        address _token0,
        address _token1,
        uint24 _fee,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) external {
        start();

        console.log("Creating Uniswap V3 Position...");
        console.log("  Token0:", _token0);
        console.log("  Token1:", _token1);
        console.log("  Fee:", uint256(_fee).toString());
        console.log("  Token0 Amount:", _token0Amount.toString());
        console.log("  Token1 Amount:", _token1Amount.toString());

        if (_token0 > _token1) {
            (_token0, _token1) = (_token1, _token0);
            (_token0Amount, _token1Amount) = (_token1Amount, _token0Amount);
        }

        // get tickSpacing
        address factoryAddress = getAddress("v3CoreFactoryAddress");
        require(factoryAddress != address(0), "UniswapV3Factory address not found");
        v3CoreFactory = UniswapV3Factory(factoryAddress);

        address poolAddr = v3CoreFactory.getPool(_token0, _token1, _fee);
        require(poolAddr != address(0), "UNKNOWN_POOL");
        v3Pool = UniswapV3Pool(poolAddr);
        int24 tickSpacing = v3Pool.tickSpacing();

        address nonfungiblePositionManagerAddress = getAddress("nftPositionManagerAddress");
        require(nonfungiblePositionManagerAddress != address(0), "NonfungiblePositionManager address not found");
        nonfungiblePositionManager = INonfungiblePositionManager(nonfungiblePositionManagerAddress);

        // add allowance
        uint256 maxApproval = 2**256 - 1;
        TransferHelper.safeApprove(_token0, address(nonfungiblePositionManager), maxApproval);
        TransferHelper.safeApprove(_token1, address(nonfungiblePositionManager), maxApproval);

        // mint position
        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: _token0,
                token1: _token1,
                fee: _fee,
                tickLower: (TickMath.MIN_TICK / tickSpacing) * tickSpacing,
                tickUpper: (TickMath.MAX_TICK / tickSpacing) * tickSpacing,
                amount0Desired: _token0Amount,
                amount1Desired: _token1Amount,
                amount0Min: 1,
                amount1Min: 1,
                recipient: msg.sender,
                deadline: block.timestamp + 600
            });

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = nonfungiblePositionManager.mint(params);
        console.log(unicode"  ✓ Position created:");
        console.log("    Token ID:", tokenId.toString());
        console.log("    Liquidity:", uint256(liquidity).toString());
        console.log("    Amount0:", amount0.toString());
        console.log("    Amount1:", amount1.toString());

        // Remove allowance
        TransferHelper.safeApprove(_token0, address(nonfungiblePositionManager), 0);
        TransferHelper.safeApprove(_token1, address(nonfungiblePositionManager), 0);

        end();
    }
}
