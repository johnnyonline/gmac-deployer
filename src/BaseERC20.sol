// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20, ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import {BaseToken, IUniswapV2Router01} from "./BaseToken.sol";

contract BaseERC20 is ERC20Capped, BaseToken {

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) ERC20Capped(_totalSupply) BaseToken(_wnt, _univ2) {
        _mint(address(this), _totalSupply);
    }
}