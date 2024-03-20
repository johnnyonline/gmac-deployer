// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "@uniswap-core/interfaces/IUniswapV2Factory.sol";

import {TaxHelper} from "src/TaxHelper.sol";
import {ERC20TokenFactory} from "src/ERC20/ERC20TokenFactory.sol";
import {ERC404TokenFactory} from "src/ERC404/ERC404TokenFactory.sol";
import {BaseToken} from "src/BaseToken.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract Base is Test {

    using SafeERC20 for IERC20;

    struct ForkIDs {
        uint256 mainnet;
        uint256 arbitrum;
        uint256 fraxtal;
        uint256 avalanche;
        uint256 goerli;
        uint256 sepolia;
        uint256 base;
    }

    ForkIDs public forkIDs;

    address payable public userEthereum;
    address payable public userArbitrum;
    address payable public userFraxtal;
    address payable public userAvalanche;
    address payable public userGoerli;
    address payable public userSepolia;
    address payable public userBase;

    address public constant TREASURY = address(0xD8984d5D0A68FD6ec1051C638906de686cD696E2);

    IERC20 public constant WETH_ETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant WETH_ARBITRUM = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 public constant WFRXETH_FRAXTAL = IERC20(0xFC00000000000000000000000000000000000006);
    IERC20 public constant WAVAX = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
    IERC20 public constant WETH_GOERLI = IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    IERC20 public constant WETH_SEPOLIA = IERC20(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    IERC20 public constant WETH_BASE = IERC20(0x4200000000000000000000000000000000000006);

    IUniswapV2Router01 public constant UNIV2_ROUTER_ETH = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // also on Goerli
    IUniswapV2Router01 public constant UNIV2_ROUTER_ARBITRUM = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    IUniswapV2Router01 public constant UNIV2_ROUTER_FRAXTAL = IUniswapV2Router01(0x2Dd1B4D4548aCCeA497050619965f91f78b3b532);
    IUniswapV2Router01 public constant UNIV2_ROUTER_AVAX = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    IUniswapV2Router01 public constant UNIV2_ROUTER_SEPOLIA = IUniswapV2Router01(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
    IUniswapV2Router01 public constant UNIV2_ROUTER_BASE = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);

    IUniswapV2Factory public constant UNIV2_FACTORY_ETH = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); // also on Goerli
    IUniswapV2Factory public constant UNIV2_FACTORY_ARBITRUM = IUniswapV2Factory(0xf1D7CC64Fb4452F05c498126312eBE29f30Fbcf9);
    IUniswapV2Factory public constant UNIV2_FACTORY_FRAXTAL = IUniswapV2Factory(0xE30521fe7f3bEB6Ad556887b50739d6C7CA667E6);
    IUniswapV2Factory public constant UNIV2_FACTORY_AVAX = IUniswapV2Factory(0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C);
    IUniswapV2Factory public constant UNIV2_FACTORY_SEPOLIA = IUniswapV2Factory(0x7E0987E5b3a30e3f2828572Bb659A548460a3003);
    IUniswapV2Factory public constant UNIV2_FACTORY_BASE = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    ERC20TokenFactory public erc20TokenFactoryMainnet;
    ERC20TokenFactory public erc20TokenFactoryArbitrum;
    ERC20TokenFactory public erc20TokenFactoryFraxtal;
    ERC20TokenFactory public erc20TokenFactoryAvalanche;
    ERC20TokenFactory public erc20TokenFactoryGoerli;
    ERC20TokenFactory public erc20TokenFactorySepolia;
    ERC20TokenFactory public erc20TokenFactoryBase;

    ERC404TokenFactory public erc404TokenFactoryMainnet;
    ERC404TokenFactory public erc404TokenFactoryArbitrum;
    ERC404TokenFactory public erc404TokenFactoryFraxtal;
    ERC404TokenFactory public erc404TokenFactoryAvalanche;
    ERC404TokenFactory public erc404TokenFactoryGoerli;
    ERC404TokenFactory public erc404TokenFactorySepolia;
    ERC404TokenFactory public erc404TokenFactoryBase;

    // ============================================================================================
    // Test Setup
    // ============================================================================================

    function setUp() public virtual {

        forkIDs = ForkIDs({
            mainnet: vm.createFork(vm.envString("ETHEREUM_RPC_URL")),
            arbitrum: vm.createFork(vm.envString("ARBITRUM_RPC_URL")),
            fraxtal: vm.createFork(vm.envString("FRAXTAL_RPC_URL")),
            avalanche: vm.createFork(vm.envString("AVALANCHE_RPC_URL")),
            goerli: vm.createFork(vm.envString("GOERLI_RPC_URL")),
            sepolia: vm.createFork(vm.envString("SEPOLIA_RPC_URL")),
            base: vm.createFork(vm.envString("BASE_RPC_URL"))
        });

        // deploy on Ethereum
        vm.selectFork(forkIDs.mainnet);
        userEthereum = _createUser(WETH_ETH);
        (erc20TokenFactoryMainnet, erc404TokenFactoryMainnet) = _deployFactory(WETH_ETH, UNIV2_ROUTER_ETH, UNIV2_FACTORY_ETH);

        // deploy on Arbitrum
        vm.selectFork(forkIDs.arbitrum);
        userArbitrum = _createUser(WETH_ARBITRUM);
        (erc20TokenFactoryArbitrum, erc404TokenFactoryArbitrum) = _deployFactory(WETH_ARBITRUM, UNIV2_ROUTER_ARBITRUM, UNIV2_FACTORY_ARBITRUM);

        // deploy on Fraxtal
        vm.selectFork(forkIDs.fraxtal);
        userFraxtal = _createUser(WFRXETH_FRAXTAL);
        (erc20TokenFactoryFraxtal, erc404TokenFactoryFraxtal) = _deployFactory(WFRXETH_FRAXTAL, UNIV2_ROUTER_FRAXTAL, UNIV2_FACTORY_FRAXTAL);

        // deploy on Avalanche
        vm.selectFork(forkIDs.avalanche);
        userAvalanche = _createUser(WAVAX);
        (erc20TokenFactoryAvalanche, erc404TokenFactoryAvalanche) = _deployFactory(WAVAX, UNIV2_ROUTER_AVAX, UNIV2_FACTORY_AVAX);

        // deploy on Goerli
        vm.selectFork(forkIDs.goerli);
        userGoerli = _createUser(WETH_GOERLI);
        (erc20TokenFactoryGoerli, erc404TokenFactoryGoerli) = _deployFactory(WETH_GOERLI, UNIV2_ROUTER_ETH, UNIV2_FACTORY_ETH);

        // deploy on Sepolia
        vm.selectFork(forkIDs.sepolia);
        userSepolia = _createUser(WETH_SEPOLIA);
        (erc20TokenFactorySepolia, erc404TokenFactorySepolia) = _deployFactory(WETH_SEPOLIA, UNIV2_ROUTER_SEPOLIA, UNIV2_FACTORY_SEPOLIA);

        // deploy on Base
        vm.selectFork(forkIDs.base);
        userBase = _createUser(WETH_BASE);
        (erc20TokenFactoryBase, erc404TokenFactoryBase) = _deployFactory(WETH_BASE, UNIV2_ROUTER_BASE, UNIV2_FACTORY_BASE);
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _deployFactory(IERC20 _wnt, IUniswapV2Router01 _univ2router, IUniswapV2Factory _univ2factory) internal returns (ERC20TokenFactory _erc20Factory, ERC404TokenFactory _erc404Factory) {
        TaxHelper _taxHelper = new TaxHelper();
        _erc20Factory = new ERC20TokenFactory(_wnt, _univ2router, _univ2factory, _taxHelper, TREASURY);
        _erc404Factory = new ERC404TokenFactory(_wnt, _univ2router, _univ2factory, _taxHelper, TREASURY);
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
        uint256 _treasuryWntBalanceBefore = _wnt.balanceOf(TREASURY);
        uint256 _amount = 1 ether;
        _wnt.forceApprove(address(_token), _amount);
        _token.swap(_amount, 0, _user, false);

        assertTrue(IERC20(address(_token)).balanceOf(_user) > 0, "_testSwap: E1");
        assertEq(_wnt.balanceOf(_user), _userWntBalanceBefore - 1 ether, "_testSwap: E2");
        assertEq(_wnt.balanceOf(TREASURY), _treasuryWntBalanceBefore + 0.0025 ether, "_testSwap: E3");
        assertEq(_userTokenBalanceBefore, 0, "_testSwap: E4");

        // ************************
        // Swap Token for WNT
        // ************************

        _userWntBalanceBefore = _wnt.balanceOf(_user);
        _amount = IERC20(address(_token)).balanceOf(_user);
        _treasuryWntBalanceBefore = _wnt.balanceOf(TREASURY);
        IERC20(address(_token)).forceApprove(address(_token), _amount);
        _token.swap(_amount, 0, _user, true);
        uint256 _wntEarned = _wnt.balanceOf(_user) - _userWntBalanceBefore;

        assertTrue(_wntEarned > 0, "_testSwap: E5");
        assertEq(IERC20(address(_token)).balanceOf(_user), 0, "_testSwap: E6");
        assertApproxEqAbs(_wnt.balanceOf(TREASURY), _treasuryWntBalanceBefore + (_wntEarned * 25 / 10000), 1e14, "_testSwap: E7");

        vm.stopPrank();
    }
}