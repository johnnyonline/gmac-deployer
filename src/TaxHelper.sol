// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title TaxHelper
/// @notice A helper contract to handle tax and transfer of WNTs
/// @dev We use this contract because UniswapV2 can't send tokens to the token contract itself
contract TaxHelper {

    event TaxAndTransfer(uint256 amountAfterTax, uint256 taxAmount, address indexed token, address tokenReceiver, address taxReceiver);

    using SafeERC20 for IERC20;

    /// @notice Tax and transfer WNTs to the token receiver and the tax receiver
    /// @param _tax The tax amount
    /// @param _precision The precision
    /// @param _token The token address
    /// @param _tokenReceiver The token receiver address
    /// @param _taxReceiver The tax receiver address
    /// @return The tax amount
    function taxAndTransfer(
        uint256 _tax,
        uint256 _precision,
        address _token,
        address _tokenReceiver,
        address _taxReceiver
    ) external returns (uint256) {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        uint256 _taxAmount = _amount * _tax / _precision;
        uint256 _amountAfterTax = _amount - _taxAmount;

        emit TaxAndTransfer(_amountAfterTax, _taxAmount, _token, _tokenReceiver, _taxReceiver);

        IERC20(_token).safeTransfer(_taxReceiver, _taxAmount);
        IERC20(_token).safeTransfer(_tokenReceiver, _amountAfterTax);

        return _taxAmount;
    }
}