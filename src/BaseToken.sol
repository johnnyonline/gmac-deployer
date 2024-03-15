// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";

import {TaxHelper} from "./TaxHelper.sol";

/// @title BaseToken
/// @notice A base contract for all tokens
abstract contract BaseToken is ReentrancyGuard {

    using SafeERC20 for IERC20;

    address public immutable treasury;

    IERC20 public immutable wnt;
    IUniswapV2Router01 public immutable univ2router;
    TaxHelper public immutable taxHelper;

    uint256 public constant SWAP_TAX = 25; // 0.25%
    uint256 public constant PRECISION = 10000;

    // ============================================================================================
    // Constructor
    // ============================================================================================

    constructor(IERC20 _wnt, IUniswapV2Router01 _univ2router, TaxHelper _taxHelper, address _treasury) {
        wnt = _wnt;
        univ2router = _univ2router;
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
    // External Functions
    // ============================================================================================

    /// @notice Swap tokens and pay tax
    /// @param _amount The amount in
    /// @param _minOut The minimum amount out
    /// @param _receiver The receiver address
    /// @param _fromToken True if from token, false if from WNT
    function swap(
        uint256 _amount,
        uint256 _minOut,
        address _receiver,
        bool _fromToken
    ) external nonReentrant {
        if (_amount == 0) revert InvalidAmount();

        uint256 _tax = 0;
        address[] memory _path = new address[](2);
        if (_fromToken) {
            IERC20(address(this)).safeTransferFrom(msg.sender, address(this), _amount);
            IERC20(address(this)).forceApprove(address(univ2router), _amount);

            _path[0] = address(this);
            _path[1] = address(wnt);
        } else {
            wnt.safeTransferFrom(msg.sender, address(this), _amount);

            _path[0] = address(wnt);
            _path[1] = address(this);

            _tax = _amount * SWAP_TAX / PRECISION;
            _amount -= _tax;

            wnt.forceApprove(address(univ2router), _amount);
            wnt.safeTransfer(treasury, _tax);
        }

        // slither-disable-next-line unused-return
        univ2router.swapExactTokensForTokens(
            _amount, // amountIn
            _minOut, // amountOutMin
            _path, // path
            _fromToken ? address(taxHelper) : _receiver, // to
            block.timestamp // deadline
        );

        if (_fromToken) _tax = taxHelper.taxAndTransfer(SWAP_TAX, PRECISION, address(wnt), _receiver, treasury);

        emit Swap(_tax, _fromToken);
    }

    // ============================================================================================
    // Events
    // ============================================================================================

    event Swap(uint256 tax, bool fromToken);

    // ============================================================================================
    // Errors
    // ============================================================================================

    error InvalidAmount();
}