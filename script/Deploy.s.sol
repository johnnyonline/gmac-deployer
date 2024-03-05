// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "@uniswap-core/interfaces/IUniswapV2Factory.sol";

import {ERC20TokenFactory} from "src/ERC20/ERC20TokenFactory.sol";
import {ERC404TokenFactory} from "src/ERC404/ERC404TokenFactory.sol";
import {TaxHelper} from "src/TaxHelper.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

// ---- Usage ----
// forge script script/Deploy.s.sol:Deploy --verify --legacy --etherscan-api-key $KEY --verifier-url https://api-sepolia.etherscan.io/api --rpc-url $RPC_URL --broadcast

contract Deploy is Script {

    IERC20 public constant WETH_SEPOLIA = IERC20(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    IUniswapV2Router01 public constant UNIV2_ROUTER_SEPOLIA = IUniswapV2Router01(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
    IUniswapV2Factory public constant UNIV2_FACTORY_SEPOLIA = IUniswapV2Factory(0x7E0987E5b3a30e3f2828572Bb659A548460a3003);

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        TaxHelper _taxHelper = new TaxHelper();
        ERC20TokenFactory _erc20factory = new ERC20TokenFactory(
            WETH_SEPOLIA,
            UNIV2_ROUTER_SEPOLIA,
            UNIV2_FACTORY_SEPOLIA,
            _taxHelper,
            vm.envAddress("DEPLOYER_ADDRESS")
        );
        ERC404TokenFactory _erc404factory = new ERC404TokenFactory(
            WETH_SEPOLIA,
            UNIV2_ROUTER_SEPOLIA,
            UNIV2_FACTORY_SEPOLIA,
            _taxHelper,
            vm.envAddress("DEPLOYER_ADDRESS")
        );

        console.log("*******************************");
        console.log("ERC20TokenFactory: ", address(_erc20factory));
        console.log("ERC404TokenFactory: ", address(_erc404factory));
        console.log("*******************************");

        vm.stopBroadcast();
    }
}

// ERC20TokenFactory:  0x81BaF53eAD9e00937D16604dF9087B7875710368
// ERC404TokenFactory:  0x17668e758ACFaba582886f690F1aeb5900f5C7A8