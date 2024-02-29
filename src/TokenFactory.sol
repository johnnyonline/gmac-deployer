// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IUniswapV2Router01} from "@uniswap/interfaces/IUniswapV2Router01.sol";

import {BaseERC20, IERC20} from "./BaseERC20.sol";
import {BaseERC404} from "./BaseERC404.sol";

contract TokenFactory {

    using SafeERC20 for IERC20;

    IERC20 public immutable WNT;
    IUniswapV2Router01 public immutable univ2;

    constructor(IERC20 _wnt, IUniswapV2Router01 _univ2) {
        WNT = _wnt;
        univ2 = _univ2;
    }

    function createERC20(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _wntAmount
    ) external returns (address) {
        BaseERC20 _token = new BaseERC20(WNT, univ2, _name, _symbol, _totalSupply);

        WNT.safeTransferFrom(msg.sender, address(_token), _wntAmount);

        _token.addLiquidityAndBurn();

        return address(_token);
    }

    // function createERC404() // TODO
}