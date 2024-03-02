// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20, ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import {BaseToken, IUniswapV2Router01, IERC20} from "./BaseToken.sol";

contract BaseERC20 is ERC20Capped, BaseToken {

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2,
        address _treasury,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) ERC20Capped(_totalSupply) BaseToken(_wnt, _univ2, _treasury) {
        _mint(address(this), _totalSupply);
    }
}