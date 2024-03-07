// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "@uniswap-core/interfaces/IUniswapV2Factory.sol";

import {TaxHelper, SafeERC20, IERC20} from "./TaxHelper.sol";

/// @title BaseFactory
/// @notice A base factory contract to create new non-ruggable ERC20/ERC404 tokens
abstract contract BaseFactory is ReentrancyGuard {

    using SafeERC20 for IERC20;
    using Address for address payable;

    address public immutable treasury;

    IERC20 public immutable wnt;
    IUniswapV2Router01 public immutable univ2router;
    IUniswapV2Factory public immutable univ2factory;
    TaxHelper public immutable taxHelper;

    // ============================================================================================
    // Constructor
    // ============================================================================================

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2router,
        IUniswapV2Factory _univ2factory,
        TaxHelper _taxHelper,
        address _treasury
    ) {
        if (_treasury == address(0)) revert InvalidAddress();

        wnt = _wnt;
        univ2router = _univ2router;
        univ2factory = _univ2factory;
        taxHelper = _taxHelper;

        treasury = _treasury;

        if (block.chainid == 252) {
            // https://docs.frax.com/fraxtal/fraxtal-incentives/fraxtal-incentives-delegation#setting-delegations-for-smart-contracts
            address _delegationRegistry = 0x4392dC16867D53DBFE227076606455634d4c2795;
            _delegationRegistry.call(abi.encodeWithSignature("setDelegationForSelf(address)", _treasury));
            _delegationRegistry.call(abi.encodeWithSignature("disableSelfManagingDelegations()"));
        }
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _addLiquidityAndBurn(address _token) internal returns (address _pair) {
        if (msg.value == 0) revert InvalidAmount();

        payable(address(wnt)).functionCallWithValue(abi.encodeWithSignature("deposit()"), msg.value);

        uint256 _amountToken = IERC20(_token).balanceOf(address(this));
        uint256 _amountWNT = wnt.balanceOf(address(this));
        // slither-disable-next-line incorrect-equality
        if (_amountToken == 0 || _amountWNT == 0) revert InvalidAmount();

        _pair = univ2factory.createPair(_token, address(wnt));

        IERC20(_token).forceApprove(address(univ2router), _amountToken);
        wnt.forceApprove(address(univ2router), _amountWNT);

        uint256 _liquidity = 0;
        (_amountToken, _amountWNT, _liquidity) = univ2router.addLiquidity(
            _token, // tokenA
            address(wnt), // tokenB
            _amountToken, // amountADesired
            _amountWNT, // amountBDesired
            _amountToken, // amountAMin
            _amountWNT, // amountBMin
            address(0), // to
            block.timestamp // deadline
        );

        emit AddLiquidityAndBurn(_amountToken, _amountWNT, _liquidity, _pair);
    }

    // ============================================================================================
    // Events
    // ============================================================================================

    event AddLiquidityAndBurn(uint256 amountToken, uint256 amountWNT, uint256 liquidity, address pair);
    event TokenCreated(address token, string name, string symbol, uint256 totalSupply);

    // ============================================================================================
    // Errors
    // ============================================================================================

    error InvalidAmount();
    error InvalidAddress();
}