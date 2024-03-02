// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IUniswapV2Router01} from "@uniswap/interfaces/IUniswapV2Router01.sol";

import {BaseERC20, BaseToken, IERC20} from "./BaseERC20.sol";
import {BaseERC404} from "./BaseERC404.sol";

contract TokenFactory {

    using SafeERC20 for IERC20;

    address public immutable TREASURY;

    IERC20 public immutable WNT;
    IUniswapV2Router01 public immutable univ2;

    constructor(IERC20 _wnt, IUniswapV2Router01 _univ2, address _treasury) {
        WNT = _wnt;
        univ2 = _univ2;

        TREASURY = _treasury;
    }

    function createERC20(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _wntAmount
    ) external returns (address) {
        BaseERC20 _token = new BaseERC20(
            WNT,
            univ2,
            TREASURY,
            _name,
            _symbol,
            _totalSupply
        );

        return _addLiquidityAndBurn(BaseToken(_token), _wntAmount);
    }

    function createERC404(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint96 _totalSupply,
        uint256 _wntAmount
    ) external returns (address) {
        BaseERC404 _token = new BaseERC404(
            WNT,
            univ2,
            TREASURY,
            _name,
            _symbol,
            _baseURI,
            _totalSupply
        );

        return _addLiquidityAndBurn(BaseToken(_token), _wntAmount);
    }

    function _addLiquidityAndBurn(BaseToken _token, uint256 _wntAmount) internal returns (address) {
        WNT.safeTransferFrom(msg.sender, address(_token), _wntAmount);

        _token.addLiquidityAndBurn();

        return address(_token);
    }
}