// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Ethereum.s.sol:Ethereum --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Ethereum is BaseDeployer {

    IERC20 public constant WETH_ETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV2Router01 public constant UNIV2_ROUTER_ETH = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant UNIV2_FACTORY_ETH = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    function run() public {
        _deploy(WETH_ETH, UNIV2_ROUTER_ETH, UNIV2_FACTORY_ETH);
    }
}