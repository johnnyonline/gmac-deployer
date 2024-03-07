// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Avalanche.s.sol:Avalanche --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Avalanche is BaseDeployer {

    IERC20 public constant WAVAX = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
    IUniswapV2Router01 public constant UNIV2_ROUTER_AVAX = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    IUniswapV2Factory public constant UNIV2_FACTORY_AVAX = IUniswapV2Factory(0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C);

    function run() public {
        _deploy(WAVAX, UNIV2_ROUTER_AVAX, UNIV2_FACTORY_AVAX);
    }
}