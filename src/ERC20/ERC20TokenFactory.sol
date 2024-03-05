// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseFactory, TaxHelper, IERC20, IUniswapV2Factory, IUniswapV2Router01} from "../BaseFactory.sol";

import {BaseERC20} from "./BaseERC20.sol";

/// @title ERC20TokenFactory
/// @notice A factory contract to create new non-ruggable ERC20 tokens
contract ERC20TokenFactory is BaseFactory {

    // ============================================================================================
    // Constructor
    // ============================================================================================

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2router,
        IUniswapV2Factory _univ2factory,
        TaxHelper _taxHelper,
        address _treasury
    ) BaseFactory(_wnt, _univ2router, _univ2factory, _taxHelper, _treasury) {}

    // ============================================================================================
    // External Functions
    // ============================================================================================

    /// @notice Create a new ERC20 token, add liquidity and burn the LP tokens
    /// @param _name The token name
    /// @param _symbol The token symbol
    /// @param _totalSupply The total supply
    /// @return The pair address and the token address
    function createERC20(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) external payable nonReentrant returns (address, address) {
        BaseERC20 _token = new BaseERC20(
            wnt,
            univ2router,
            taxHelper,
            treasury,
            _name,
            _symbol,
            _totalSupply
        );

        emit TokenCreated(address(_token), _name, _symbol, _totalSupply);

        return (_addLiquidityAndBurn(address(_token)), address(_token));
    }
}