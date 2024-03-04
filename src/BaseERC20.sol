// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20, ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import {BaseToken, FeeHelper, IUniswapV2Router01, IERC20} from "./BaseToken.sol";

/// @title BaseERC20
/// @notice A standard ERC20 token
contract BaseERC20 is ERC20Capped, BaseToken {

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2router,
        FeeHelper _feeHelper,
        address _treasury,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) ERC20Capped(_totalSupply) BaseToken(_wnt, _univ2router, _feeHelper, _treasury) {
        _mint(
            msg.sender, // TokenFactory
            _totalSupply // maxSupply
        );
    }
}