// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import { UniswapInterfaceMulticall } from "@uniswap/v3-periphery/contracts/lens/UniswapInterfaceMulticall.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/ProxyAdmin.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
import { TickLens } from "@uniswap/v3-periphery/contracts/lens/TickLens.sol";
import {
    NonfungibleTokenPositionDescriptor
} from "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {
    INonfungiblePositionManager
} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import { NonfungiblePositionManager } from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";
import { V3Migrator } from "@uniswap/v3-periphery/contracts/V3Migrator.sol";
import { UniswapV3Staker } from "@uniswap/v3-staker/contracts/UniswapV3Staker.sol";
import { QuoterV2 } from "@uniswap/v3-periphery/contracts/lens/QuoterV2.sol";
import { SwapRouter02 } from "@uniswap/swap-router-contracts/contracts/SwapRouter02.sol";

import { DeployScript } from "./DeployScript.s.sol";
import { Script, console } from "forge-std/Script.sol";

contract DeployUniswapV3 is DeployScript {
    address private weth9;
    bytes32 private nativeCurrencyLabel;

    UniswapV3Factory private v3CoreFactory;

    function run(string calldata _nativeCurrencyLabel) external {
        start();

        weth9 = getAddress("weth9Address");
        require(weth9 != address(0), "WETH9 address not found");

        nativeCurrencyLabel = asciiStringToBytes32(_nativeCurrencyLabel);

        console.log("Deploying Uniswap V3 Protocol...");

        deployV3CoreFactory();
        add1BPFeeTier();
        deployMulticall2();
        deployProxyAdmin();
        deployTickLens();
        deployNFTPositionDescriptor();
        deployTransparentProxyDescriptor();
        deployNonfungiblePositionManager();
        deployV3Migrator();
        deployV3Staker();
        deployQuoterV2();
        deployV3SwapRouter02();

        end();
    }

    function deployV3CoreFactory() internal {
        address v3CoreFactoryAddr = getAddress("v3CoreFactoryAddress");
        if (v3CoreFactoryAddr == address(0)) {
            console.log("Deploying V3 Core Factory...");
            v3CoreFactory = new UniswapV3Factory();
            console.log(unicode"  ✓ V3 Core Factory deployed at:", address(v3CoreFactory));
            setAddress("v3CoreFactoryAddress", address(v3CoreFactory));
        } else {
            console.log("Loading existing V3 Core Factory...");
            v3CoreFactory = UniswapV3Factory(v3CoreFactoryAddr);
            console.log(unicode"  ✓ V3 Core Factory loaded from:", v3CoreFactoryAddr);
        }
    }

    function add1BPFeeTier() internal {
        uint24 ONE_BP_FEE = 100;
        int24 ONE_BP_TICK_SPACING = 1;
        if (v3CoreFactory.feeAmountTickSpacing(ONE_BP_FEE) == 0) {
            console.log("Adding 1BP Fee Tier...");
            v3CoreFactory.enableFeeAmount(ONE_BP_FEE, ONE_BP_TICK_SPACING);
        } else {
            console.log(unicode"✓ 1BP Fee Tier exists");
        }
    }

    function deployMulticall2() internal {
        address multicall2Addr = getAddress("multicall2Address");
        if (multicall2Addr == address(0)) {
            console.log("Deploying Multicall2...");
            UniswapInterfaceMulticall multicall2 = new UniswapInterfaceMulticall();
            console.log(unicode"  ✓ Multicall2 deployed at:", address(multicall2));
            setAddress("multicall2Address", address(multicall2));
        } else {
            console.log(unicode"✓ Multicall2 already deployed at:", multicall2Addr);
        }
    }

    function deployProxyAdmin() internal {
        address proxyAdminAddr = getAddress("proxyAdminAddress");
        if (proxyAdminAddr == address(0)) {
            console.log("Deploying Proxy Admin...");
            ProxyAdmin proxy = new ProxyAdmin();
            console.log(unicode"  ✓ Proxy Admin deployed at:", address(proxy));
            setAddress("proxyAdminAddress", address(proxy));
        } else {
            console.log(unicode"✓ Proxy Admin already deployed at:", proxyAdminAddr);
        }
    }

    function deployTickLens() internal {
        address tickLensAddr = getAddress("tickLensAddress");
        if (tickLensAddr == address(0)) {
            console.log("Deploying Tick Lens...");
            TickLens tickLens = new TickLens();
            console.log(unicode"  ✓ Tick Lens deployed at:", address(tickLens));
            setAddress("tickLensAddress", address(tickLens));
        } else {
            console.log(unicode"✓ Tick Lens already deployed at:", tickLensAddr);
        }
    }

    function deployNFTPositionDescriptor() internal {
        address nftPositionDescriptorAddr = getAddress("nftPositionDescriptorAddress");
        if (nftPositionDescriptorAddr == address(0)) {
            console.log("Deploying NFT Position Descriptor...");
            NonfungibleTokenPositionDescriptor nftPositionDescriptor = new NonfungibleTokenPositionDescriptor(
                address(weth9),
                nativeCurrencyLabel
            );
            console.log(unicode"  ✓ NFT Position Descriptor deployed at:", address(nftPositionDescriptor));
            setAddress("nftPositionDescriptorAddress", address(nftPositionDescriptor));
        } else {
            console.log(unicode"✓ NFT Position Descriptor already deployed at:", nftPositionDescriptorAddr);
        }
    }

    function deployTransparentProxyDescriptor() internal {
        address descriptorProxyAddress = getAddress("descriptorProxyAddress");
        if (descriptorProxyAddress == address(0)) {
            address proxyAdmin = getAddress("proxyAdminAddress");
            address nftPositionDescriptor = getAddress("nftPositionDescriptorAddress");
            require(proxyAdmin != address(0), "ProxyAdmin not deployed");
            require(nftPositionDescriptor != address(0), "NFTPositionDescriptor not deployed");

            console.log("Deploying Transparent Proxy for NFT Position Descriptor...");
            TransparentUpgradeableProxy transparentProxy = new TransparentUpgradeableProxy(
                nftPositionDescriptor,
                proxyAdmin,
                ""
            );
            console.log(unicode"  ✓ TransparentUpgradeableProxy deployed at:", address(transparentProxy));
            setAddress("descriptorProxyAddress", address(transparentProxy));
        } else {
            console.log(
                unicode"✓ Transparent Proxy for NFT Position Descriptor already deployed at:",
                descriptorProxyAddress
            );
        }
    }

    function deployNonfungiblePositionManager() internal {
        address nftPositionManagerAddress = getAddress("nftPositionManagerAddress");
        if (nftPositionManagerAddress == address(0)) {
            console.log("Deploying Nonfungible Position Manager...");
            address factory = getAddress("v3CoreFactoryAddress");
            address weth9Address = address(weth9);
            address descriptorProxyAddress = getAddress("descriptorProxyAddress");
            require(factory != address(0), "V3 Core Factory not deployed");
            require(descriptorProxyAddress != address(0), "Transparent Proxy for NFT Position Descriptor not deployed");

            NonfungiblePositionManager nftPositionManager = new NonfungiblePositionManager(
                factory,
                weth9Address,
                descriptorProxyAddress
            );
            console.log(unicode"  ✓ Nonfungible Position Manager deployed at:", address(nftPositionManager));
            setAddress("nftPositionManagerAddress", address(nftPositionManager));
        } else {
            console.log(unicode"✓ Nonfungible Position Manager already deployed at:", nftPositionManagerAddress);
        }
    }

    function deployV3Migrator() internal {
        address v3MigratorAddress = getAddress("v3MigratorAddress");
        if (v3MigratorAddress == address(0)) {
            console.log("Deploying V3 Migrator...");
            address factory = getAddress("v3CoreFactoryAddress");
            address weth9Address = address(weth9);
            address nonfungiblePositionManager = getAddress("nftPositionManagerAddress");
            require(factory != address(0), "V3 Core Factory not deployed");
            require(nonfungiblePositionManager != address(0), "Nonfungible Position Manager not deployed");

            V3Migrator v3Migrator = new V3Migrator(factory, weth9Address, nonfungiblePositionManager);
            console.log(unicode"  ✓ V3 Migrator deployed at:", address(v3Migrator));
            setAddress("v3MigratorAddress", address(v3Migrator));
        } else {
            console.log(unicode"✓ V3 Migrator already deployed at:", v3MigratorAddress);
        }
    }

    function deployV3Staker() internal {
        address v3StakerAddress = getAddress("v3StakerAddress");
        if (v3StakerAddress == address(0)) {
            console.log("Deploying V3 Staker...");
            address factory = getAddress("v3CoreFactoryAddress");
            address nonfungiblePositionManager = getAddress("nftPositionManagerAddress");
            require(factory != address(0), "V3 Core Factory not deployed");
            require(nonfungiblePositionManager != address(0), "Nonfungible Position Manager not deployed");

            uint256 ONE_MINUTE_SECONDS = 60;
            uint256 ONE_HOUR_SECONDS = ONE_MINUTE_SECONDS * 60;
            uint256 ONE_DAY_SECONDS = ONE_HOUR_SECONDS * 24;
            uint256 ONE_MONTH_SECONDS = ONE_DAY_SECONDS * 30;
            uint256 ONE_YEAR_SECONDS = ONE_DAY_SECONDS * 365;
            uint256 MAX_INCENTIVE_START_LEAD_TIME = ONE_MONTH_SECONDS;
            uint256 MAX_INCENTIVE_DURATION = ONE_YEAR_SECONDS * 2;

            UniswapV3Staker v3Staker = new UniswapV3Staker(
                IUniswapV3Factory(factory),
                INonfungiblePositionManager(nonfungiblePositionManager),
                MAX_INCENTIVE_START_LEAD_TIME,
                MAX_INCENTIVE_DURATION
            );
            console.log(unicode"  ✓ V3 Staker deployed at:", address(v3Staker));
            setAddress("v3StakerAddress", address(v3Staker));
        } else {
            console.log(unicode"✓ V3 Staker already deployed at:", v3StakerAddress);
        }
    }

    function deployQuoterV2() internal {
        address quoterV2Address = getAddress("quoterV2Address");
        if (quoterV2Address == address(0)) {
            console.log("Deploying Quoter V2...");
            address factory = getAddress("v3CoreFactoryAddress");
            address weth9Address = address(weth9);
            require(factory != address(0), "V3 Core Factory not deployed");

            QuoterV2 quoterV2 = new QuoterV2(factory, weth9Address);
            console.log(unicode"  ✓ Quoter V2 deployed at:", address(quoterV2));
            setAddress("quoterV2Address", address(quoterV2));
        } else {
            console.log(unicode"✓ Quoter V2 already deployed at:", quoterV2Address);
        }
    }

    function deployV3SwapRouter02() internal {
        address swapRouter02Address = getAddress("swapRouter02Address");
        if (swapRouter02Address == address(0)) {
            console.log("Deploying V3 Swap Router 02...");
            address factory = getAddress("v3CoreFactoryAddress");
            address nonfungiblePositionManager = getAddress("nftPositionManagerAddress");
            address weth9Address = address(weth9);
            require(factory != address(0), "V3 Core Factory not deployed");
            require(nonfungiblePositionManager != address(0), "Nonfungible Position Manager not deployed");

            SwapRouter02 swapRouter02 = new SwapRouter02(
                address(0), // none deployed
                factory,
                nonfungiblePositionManager,
                weth9Address
            );
            console.log(unicode"  ✓ V3 Swap Router 02 deployed at:", address(swapRouter02));
            setAddress("swapRouter02Address", address(swapRouter02));
        } else {
            console.log(unicode"✓ V3 Swap Router 02 already deployed at:", swapRouter02Address);
        }
    }
}
