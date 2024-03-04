// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./Base.t.sol";

contract ERC20 is Base {

    using SafeERC20 for IERC20;

    // ============================================================================================
    // Test Setup
    // ============================================================================================

    function setUp() public override {
        Base.setUp();
    }

    // ============================================================================================
    // Test Functions
    // ============================================================================================

    function testEthereum() external {
        vm.selectFork(forkIDs.mainnet);
        _deployERC20AndTestFlow(erc20TokenFactoryMainnet, WETH_ETH, userEthereum);
    }

    function testArbitrum() external {
        vm.selectFork(forkIDs.arbitrum);
        _deployERC20AndTestFlow(erc20TokenFactoryArbitrum, WETH_ARBITRUM, userArbitrum);
    }

    function testFraxtal() external {
        vm.selectFork(forkIDs.fraxtal);
        _deployERC20AndTestFlow(erc20TokenFactoryFraxtal, WFRXETH_FRAXTAL, userFraxtal);
    }

    function testAvalanche() external {
        vm.selectFork(forkIDs.avalanche);
        _deployERC20AndTestFlow(erc20TokenFactoryAvalanche, WAVAX, userAvalanche);
    }

    function testGoerli() external {
        vm.selectFork(forkIDs.goerli);
        _deployERC20AndTestFlow(erc20TokenFactoryGoerli, WETH_GOERLI, userGoerli);
    }

    function testSepolia() external {
        vm.selectFork(forkIDs.sepolia);
        _deployERC20AndTestFlow(erc20TokenFactorySepolia, WETH_SEPOLIA, userSepolia);
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _deployERC20AndTestFlow(ERC20TokenFactory _factory, IERC20 _wnt, address _user) internal {
        vm.startPrank(_user);

        _wnt.forceApprove(address(_factory), 10 ether);

        string memory _name = "TestToken";
        string memory _symbol = "TT";
        uint256 _totalSupply = 10_000_000 * 1e18;
        uint256 _wntAmount = 10 ether;
        (address _pair, address _token) = _factory.createERC20(_name, _symbol, _totalSupply, _wntAmount);

        vm.stopPrank();

        assertEq(IERC20(_token).totalSupply(), _totalSupply, "_deployERC20AndTestFlow: E1");
        assertEq(IERC20(_token).balanceOf(_pair), _totalSupply, "_deployERC20AndTestFlow: E2");
        assertEq(IERC20(_token).balanceOf(_user), 0, "_deployERC20AndTestFlow: E3");
        assertEq(IERC20(_token).balanceOf(address(_factory)), 0, "_deployERC20AndTestFlow: E4");

        _testSwap(BaseToken(_token), _wnt, _user);
    }
}
