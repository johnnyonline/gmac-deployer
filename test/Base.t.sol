// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "@uniswap-core/interfaces/IUniswapV2Factory.sol";

import {BaseToken, TaxHelper, TokenFactory} from "src/TokenFactory.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract Base is Test {

    using SafeERC20 for IERC20;

    struct ForkIDs {
        uint256 mainnet;
        uint256 arbitrum;
        uint256 fraxtal;
        uint256 avalanche;
    }

    ForkIDs public forkIDs;

    address payable public userEthereum;
    address payable public userArbitrum;
    address payable public userFraxtal;
    address payable public userAvalanche;

    address public constant TREASURY = address(0xD8984d5D0A68FD6ec1051C638906de686cD696E2);

    IERC20 public constant WETH_ETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant WETH_ARBITRUM = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    // IERC20 public constant WFRXETH_FRAXTAL = IERC20(0xfc00000000000000000000000000000000000006);
    IERC20 public constant WAVAX = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);

    IUniswapV2Router01 public constant UNIV2_ROUTER_ETH = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router01 public constant UNIV2_ROUTER_ARBITRUM = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    // IUniswapV2Router01 public constant UNIV2_ROUTER_FRAXTAL = IUniswapV2Router01(0);
    IUniswapV2Router01 public constant UNIV2_ROUTER_AVAX = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);

    IUniswapV2Factory public constant UNIV2_FACTORY_ETH = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Factory public constant UNIV2_FACTORY_ARBITRUM = IUniswapV2Factory(0xf1D7CC64Fb4452F05c498126312eBE29f30Fbcf9);
    // IUniswapV2Factory public constant UNIV2_FACTORY_FRAXTAL = IUniswapV2Factory(0);
    IUniswapV2Factory public constant UNIV2_FACTORY_AVAX = IUniswapV2Factory(0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C);

    TokenFactory public tokenFactoryMainnet;
    TokenFactory public tokenFactoryArbitrum;
    // TokenFactory public tokenFactoryFraxtal;
    TokenFactory public tokenFactoryAvalanche;

    // ============================================================================================
    // Test Setup
    // ============================================================================================

    function setUp() public virtual {

        forkIDs = ForkIDs({
            mainnet: vm.createFork(vm.envString("ETHEREUM_RPC_URL")),
            arbitrum: vm.createFork(vm.envString("ARBITRUM_RPC_URL")),
            fraxtal: vm.createFork(vm.envString("FRAXTAL_RPC_URL")),
            avalanche: vm.createFork(vm.envString("AVALANCHE_RPC_URL"))
        });

        // deploy on Ethereum
        vm.selectFork(forkIDs.mainnet);
        userEthereum = _createUser(WETH_ETH);
        tokenFactoryMainnet = _deployFactory(WETH_ETH, UNIV2_ROUTER_ETH, UNIV2_FACTORY_ETH);

        // deploy on Arbitrum
        vm.selectFork(forkIDs.arbitrum);
        userArbitrum = _createUser(WETH_ARBITRUM);
        tokenFactoryArbitrum = _deployFactory(WETH_ARBITRUM, UNIV2_ROUTER_ARBITRUM, UNIV2_FACTORY_ARBITRUM);

        // // deploy on Fraxtal
        // vm.selectFork(forkIDs.fraxtal);
        // userFraxtal = _createUser(WFRXETH_FRAXTAL);
        // tokenFactoryFraxtal = _deployFactory(WFRXETH_FRAXTAL, UNIV2_ROUTER_FRAXTAL, UNIV2_FACTORY_FRAXTAL);

        // deploy on Avalanche
        vm.selectFork(forkIDs.avalanche);
        userAvalanche = _createUser(WAVAX);
        tokenFactoryAvalanche = _deployFactory(WAVAX, UNIV2_ROUTER_AVAX, UNIV2_FACTORY_AVAX);
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _deployFactory(IERC20 _wnt, IUniswapV2Router01 _univ2router, IUniswapV2Factory _univ2factory) internal returns (TokenFactory _factory) {
        TaxHelper _taxHelper = new TaxHelper();
        _factory = new TokenFactory(_wnt, _univ2router, _univ2factory, _taxHelper, TREASURY);
    }

    function _createUser(IERC20 _wnt) internal returns (address payable _user) {
        _user = payable(makeAddr("user"));
        vm.deal({ account: _user, newBalance: 100 ether });
        deal({ token: payable(address(_wnt)), to: _user, give: 100 ether });
    }

    function _testSwap(BaseToken _token, IERC20 _wnt, address _user) internal {

        // ************************
        // Swap WNT for Token
        // ************************

        vm.startPrank(_user);

        uint256 _userWntBalanceBefore = _wnt.balanceOf(_user);
        uint256 _userTokenBalanceBefore = IERC20(address(_token)).balanceOf(_user);
        uint256 _amount = 1 ether;
        _wnt.forceApprove(address(_token), _amount);
        _token.swap(_amount, 0, _user, false);

        assertTrue(IERC20(address(_token)).balanceOf(_user) > 0, "_testSwap: E1");
        assertEq(_wnt.balanceOf(_user), _userWntBalanceBefore - 1 ether, "_testSwap: E2");
        assertEq(_wnt.balanceOf(TREASURY), 0.0025 ether, "_testSwap: E3");
        assertEq(_userTokenBalanceBefore, 0, "_testSwap: E4");

        // ************************
        // Swap Token for WNT
        // ************************

        _userWntBalanceBefore = _wnt.balanceOf(_user);
        _amount = IERC20(address(_token)).balanceOf(_user);
        uint256 _treasuryWntBalanceBefore = _wnt.balanceOf(TREASURY);
        IERC20(address(_token)).forceApprove(address(_token), _amount);
        _token.swap(_amount, 0, _user, true);
        uint256 _wntEarned = _wnt.balanceOf(_user) - _userWntBalanceBefore;

        assertTrue(_wntEarned > 0, "_testSwap: E5");
        assertEq(IERC20(address(_token)).balanceOf(_user), 0, "_testSwap: E6");
        assertApproxEqAbs(_wnt.balanceOf(TREASURY), _treasuryWntBalanceBefore + (_wntEarned * 25 / 10000), 1e14, "_testSwap: E7");

        vm.stopPrank();
    }
}