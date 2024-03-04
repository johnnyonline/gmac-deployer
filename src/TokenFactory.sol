// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IUniswapV2Router01} from "@uniswap-periphery/interfaces/IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "@uniswap-core/interfaces/IUniswapV2Factory.sol";

import {BaseERC20, BaseToken, FeeHelper, IERC20} from "./BaseERC20.sol";
import {BaseERC404} from "./BaseERC404.sol";

/// @title TokenFactory
/// @notice A factory contract to create new non-ruggable ERC20/ERC404 tokens
contract TokenFactory is ReentrancyGuard {

    using SafeERC20 for IERC20;

    address public immutable treasury;

    IERC20 public immutable wnt;
    IUniswapV2Router01 public immutable univ2router;
    IUniswapV2Factory public immutable univ2factory;
    FeeHelper public immutable feeHelper;

    // ============================================================================================
    // Constructor
    // ============================================================================================

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2router,
        IUniswapV2Factory _univ2factory,
        FeeHelper _feeHelper,
        address _treasury
    ) {
        wnt = _wnt;
        univ2router = _univ2router;
        univ2factory = _univ2factory;
        feeHelper = _feeHelper;

        treasury = _treasury;
    }

    // ============================================================================================
    // External Functions
    // ============================================================================================

    /// @notice Create a new ERC20 token, add liquidity and burn the LP tokens
    /// @param _name The token name
    /// @param _symbol The token symbol
    /// @param _totalSupply The total supply
    /// @param _wntAmount The WNT amount
    /// @return The pair address and the token address
    function createERC20(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _wntAmount
    ) external nonReentrant returns (address, address) {
        BaseERC20 _token = new BaseERC20(
            wnt,
            univ2router,
            feeHelper,
            treasury,
            _name,
            _symbol,
            _totalSupply
        );

        return (_addLiquidityAndBurn(_wntAmount, address(_token)), address(_token));
    }

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
            feeHelper,
            treasury,
            _name,
            _symbol,
            _baseURI,
            _totalSupply
        );

        return (_addLiquidityAndBurn(_wntAmount, address(_token)), address(_token));
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _addLiquidityAndBurn(uint256 _wntAmount, address _token) internal returns (address _pair) {
        wnt.safeTransferFrom(msg.sender, address(this), _wntAmount);

        uint256 _amountToken = IERC20(_token).balanceOf(address(this));
        uint256 _amountWNT = wnt.balanceOf(address(this));
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

    // ============================================================================================
    // Errors
    // ============================================================================================

    error InvalidAmount();
}