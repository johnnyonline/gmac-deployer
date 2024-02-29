// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IUniswapV2Router01} from "@uniswap/interfaces/IUniswapV2Router01.sol";

abstract contract BaseToken {

    error InvalidAmount();

    event AddLiquidityAndBurn(uint256 _amountA, uint256 _amountB);
    event Swap(uint256 _amount, uint256 _amountOut, bool _fromToken);

    using SafeERC20 for IERC20;

    IERC20 public immutable WNT;
    IUniswapV2Router01 public immutable UNIV2;

    constructor(IERC20 _wnt, IUniswapV2Router01 _univ2) {
        WNT = _wnt;
        UNIV2 = _univ2;

    }

    function addLiquidityAndBurn() external {
        uint256 _amountA = IERC20(address(this)).balanceOf(address(this));
        uint256 _amountB = WNT.balanceOf(address(this));
        if (_amountA == 0 || _amountB == 0) revert InvalidAmount();

        emit AddLiquidityAndBurn(_amountA, _amountB);

        IERC20(address(this)).forceApprove(address(UNIV2), _amountA);
        WNT.forceApprove(address(UNIV2), _amountB);

        UNIV2.addLiquidity(
            address(this), // tokenA
            address(WNT), // tokenB
            _amountA, // amountADesired
            _amountB, // amountBDesired
            _amountA, // amountAMin
            _amountB, // amountBMin
            address(0), // to
            block.timestamp // deadline
        );
    }

    // TODO - add swap 0.25% tax on WNT and send to treasury
    function swap(uint256 _amount, uint256 _minOut, bool _fromToken) external returns (uint256 _amountOut) {
        if (_amount == 0) revert InvalidAmount();

        address[] memory _path = new address[](2);
        if (_fromToken) {
            IERC20(address(this)).safeTransferFrom(msg.sender, address(this), _amount);
            IERC20(address(this)).forceApprove(address(UNIV2), _amount);

            _path[0] = address(this);
            _path[1] = address(WNT);
        } else {
            WNT.safeTransferFrom(msg.sender, address(this), _amount);
            WNT.forceApprove(address(UNIV2), _amount);

            _path[0] = address(WNT);
            _path[1] = address(this);
        }

        _amountOut = UNIV2.swapExactTokensForTokens(
            _amount, // amountIn
            _minOut, // amountOutMin
            _path, // path
            msg.sender, // to
            block.timestamp // deadline
        )[0];

        emit Swap(_amount, _amountOut, _fromToken);
    }
}