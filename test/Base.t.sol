// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IUniswapV2Router01} from "@uniswap/interfaces/IUniswapV2Router01.sol";

import {TokenFactory} from "src/TokenFactory.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract Base is Test {

    struct ForkIDs {
        uint256 mainnet;
        uint256 arbitrum;
        uint256 fraxtal;
        uint256 avalanche;
    }

    ForkIDs public forkIDs;

    address public constant TREASURY = address(0xD8984d5D0A68FD6ec1051C638906de686cD696E2);

    IERC20 public constant WETH_ETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant WETH_ARBITRUM = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 public constant WETH_FRAXTAL = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 public constant AVAX = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);

    IUniswapV2Router01 public constant UNIV2_ETH = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router01 public constant UNIV2_ARBITRUM = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router01 public constant UNIV2_FRAXTAL = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router01 public constant UNIV2_AVAX = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    TokenFactory public tokenFactoryMainnet;
    TokenFactory public tokenFactoryArbitrum;
    TokenFactory public tokenFactoryFraxtal;
    TokenFactory public tokenFactoryAvalanche;

    function setUp() public virtual {

        forkIDs = ForkIDs({
            mainnet: vm.createFork(vm.envString("ETHEREUM_RPC_URL")),
            arbitrum: vm.createFork(vm.envString("ARBITRUM_RPC_URL")),
            fraxtal: vm.createFork(vm.envString("FRAXTAL_RPC_URL")),
            avalanche: vm.createFork(vm.envString("AVALANCHE_RPC_URL"))
        });

        // deploy on Ethereum
        vm.selectFork(forkIDs.mainnet);
        tokenFactoryMainnet = _deployFactory(WETH_ETH, UNIV2_ETH);

        // deploy on Arbitrum
        vm.selectFork(forkIDs.arbitrum);
        tokenFactoryArbitrum = _deployFactory(WETH_ARBITRUM, UNIV2_ARBITRUM);

        // deploy on Fraxtal
        vm.selectFork(forkIDs.fraxtal);
        tokenFactoryFraxtal = _deployFactory(WETH_FRAXTAL, UNIV2_FRAXTAL);

        // deploy on Avalanche
        vm.selectFork(forkIDs.avalanche);
        tokenFactoryAvalanche = _deployFactory(AVAX, UNIV2_AVAX);
    }

    function _deployFactory(IERC20 _wnt, IUniswapV2Router01 _univ2) internal returns (TokenFactory _factory) {
        _factory = new TokenFactory(_wnt, _univ2, TREASURY);
    }
}