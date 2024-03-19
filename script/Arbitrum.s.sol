// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Arbitrum.s.sol:Arbitrum --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Arbitrum is BaseDeployer {

    IERC20 public constant WETH_SEPOLIA = IERC20(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    IUniswapV2Router01 public constant UNIV2_ROUTER_SEPOLIA = IUniswapV2Router01(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
    IUniswapV2Factory public constant UNIV2_FACTORY_SEPOLIA = IUniswapV2Factory(0x7E0987E5b3a30e3f2828572Bb659A548460a3003);

    function run() public {
        _deploy(WETH_SEPOLIA, UNIV2_ROUTER_SEPOLIA, UNIV2_FACTORY_SEPOLIA);
    }
}