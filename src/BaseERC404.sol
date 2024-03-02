// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DN404} from "@vectorized/DN404.sol";
import {DN404Mirror} from "@vectorized/DN404Mirror.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {BaseToken, IUniswapV2Router01, IERC20} from "./BaseToken.sol";

contract BaseERC404 is DN404, BaseToken {

    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor(
        IERC20 _wnt,
        IUniswapV2Router01 _univ2,
        address _treasury,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint96 _totalSupply
    ) BaseToken(_wnt, _univ2, _treasury) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;

        _initializeDN404(
            _totalSupply, // initialTokenSupply
            address(this), // initialSupplyOwner
            address(new DN404Mirror(msg.sender)) // @todo address(this) / address(0) ?
        );
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory _result) {
        if (bytes(_baseURI).length != 0) _result = string(abi.encodePacked(_baseURI, Strings.toString(_tokenId)));
    }
}