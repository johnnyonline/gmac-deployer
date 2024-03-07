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

contract BaseDeployer is Script {

    function _deploy(IERC20 _weth, IUniswapV2Router01 _router, IUniswapV2Factory _factory) internal {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        address _treasury = vm.envAddress("DEPLOYER_ADDRESS");
        TaxHelper _taxHelper = new TaxHelper();
        ERC20TokenFactory _erc20factory = new ERC20TokenFactory(
            _weth,
            _router,
            _factory,
            _taxHelper,
            _treasury
        );
        ERC404TokenFactory _erc404factory = new ERC404TokenFactory(
            _weth,
            _router,
            _factory,
            _taxHelper,
            _treasury
        );

        console.log("*******************************");
        console.log("ERC20TokenFactory: ", address(_erc20factory));
        console.log("ERC404TokenFactory: ", address(_erc404factory));
        console.log("*******************************");

        vm.stopBroadcast();
    }
}