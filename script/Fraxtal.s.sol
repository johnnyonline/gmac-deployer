// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BaseDeployer.sol";

// ---- Usage ----
// forge script script/Fraxtal.s.sol:Fraxtal --verify --legacy --etherscan-api-key $KEY --verifier-url $VERIFIER_URL --rpc-url $RPC_URL --broadcast

contract Fraxtal is BaseDeployer {

    IERC20 public constant WFRXETH_FRAXTAL = IERC20(0xFC00000000000000000000000000000000000006);
    IUniswapV2Router01 public constant UNIV2_ROUTER_FRAXTAL = IUniswapV2Router01(0x2Dd1B4D4548aCCeA497050619965f91f78b3b532);
    IUniswapV2Factory public constant UNIV2_FACTORY_FRAXTAL = IUniswapV2Factory(0xE30521fe7f3bEB6Ad556887b50739d6C7CA667E6);

    function run() public {
        _deploy(WFRXETH_FRAXTAL, UNIV2_ROUTER_FRAXTAL, UNIV2_FACTORY_FRAXTAL);
    }
}