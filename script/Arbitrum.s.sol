// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Arbitrum.s.sol:Arbitrum --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Arbitrum is BaseDeployer {

    IERC20 public constant WETH_ARBITRUM = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IUniswapV2Router01 public constant UNIV2_ROUTER_ARBITRUM = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    IUniswapV2Factory public constant UNIV2_FACTORY_ARBITRUM = IUniswapV2Factory(0xf1D7CC64Fb4452F05c498126312eBE29f30Fbcf9);

    function run() public {
        _deploy(WETH_ARBITRUM, UNIV2_ROUTER_ARBITRUM, UNIV2_FACTORY_ARBITRUM);
    }
}