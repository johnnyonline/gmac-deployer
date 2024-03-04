// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseFactory, TaxHelper, IERC20, IUniswapV2Factory, IUniswapV2Router01} from "../BaseFactory.sol";

import {BaseERC404} from "./BaseERC404.sol";

/// @title ERC404TokenFactory
/// @notice A factory contract to create new non-ruggable ERC404 tokens
contract ERC404TokenFactory is BaseFactory {

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

    /// @notice Create a new ERC404 token, add liquidity and burn the LP tokens
    /// @param _name The token name
    /// @param _symbol The token symbol
    /// @param _baseURI The base URI
    /// @param _totalSupply The total supply
    /// @param _wntAmount The WNT amount
    /// @return The pair address and the token address
    function createERC404(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint96 _totalSupply,
        uint256 _wntAmount
    ) external nonReentrant returns (address, address) {
        BaseERC404 _token = new BaseERC404(
            wnt,
            univ2router,
            taxHelper,
            treasury,
            _name,
            _symbol,
            _baseURI,
            _totalSupply
        );

        emit TokenCreated(address(_token), _name, _symbol, _totalSupply);

        return (_addLiquidityAndBurn(_wntAmount, address(_token)), address(_token));
    }
}