// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Base.s.sol:Base --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Base is BaseDeployer {

    IERC20 public constant WETH_BASE = IERC20(0x4200000000000000000000000000000000000006);
    IUniswapV2Router01 public constant UNIV2_ROUTER_BASE = IUniswapV2Router01(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);
    IUniswapV2Factory public constant UNIV2_FACTORY_BASE = IUniswapV2Factory(0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6);

    function run() public {
        _deploy(WETH_BASE, UNIV2_ROUTER_BASE, UNIV2_FACTORY_BASE);
    }
}