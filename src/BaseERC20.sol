// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20, ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import {BaseToken, TaxHelper, IUniswapV2Router01, IERC20} from "./BaseToken.sol";

/// @title BaseERC20
/// @notice A standard ERC20 token
contract BaseERC20 is ERC20Capped, BaseToken {

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2router,
        TaxHelper _taxHelper,
        address _treasury,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) ERC20(name_, symbol_) ERC20Capped(totalSupply_) BaseToken(_wnt, _univ2router, _taxHelper, _treasury) {
        _mint(
            msg.sender, // TokenFactory
            totalSupply_ // maxSupply
        );
    }
}