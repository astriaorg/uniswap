// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {TransferHelper} from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import { ISwapRouter02, IV3SwapRouter } from "@uniswap/swap-router-contracts/contracts/interfaces/ISwapRouter02.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {DeployScript} from "./DeployScript.s.sol";
import {console} from "forge-std/Script.sol";

contract Swap is DeployScript {
    using Strings for uint256;

    ISwapRouter02 private swapRouter;

    function run(
        address _tokenIn,
        address _tokenOut,
        uint24 _fee,
        uint256 _amountIn
    ) external {
        start();

        console.log("Swapping tokens...");
        console.log("  Token In:", _tokenIn);
        console.log("  Token Out:", _tokenOut);
        console.log("  Fee:", uint256(_fee).toString());
        console.log("  Amount In:", _amountIn.toString());

        address swapRouter02Address = getAddress("swapRouter02Address");
        require(swapRouter02Address != address(0), "swapRouter02Address address not found");

        swapRouter = ISwapRouter02(swapRouter02Address);

        // add allowance
        uint256 maxApproval = 2**256 - 1;
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), maxApproval);

        // swap it
        ISwapRouter02.ExactInputSingleParams memory params =
          IV3SwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: _fee,
            recipient: msg.sender,
            amountIn: _amountIn,
            amountOutMinimum: 1,
            sqrtPriceLimitX96: 0
          });

        uint256 amountOut = swapRouter.exactInputSingle(params);

        console.log(unicode"  ✓ Swap completed:");
        console.log("    Amount Out:", amountOut.toString());

        // Remove allowance
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), 0);

        end();
    }
}
