// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma abicoder v2;


import "./lib/SqrtMath.sol";
import "./Token.sol";
import "./RewardToken.sol";

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";

contract PaulTokenPool is Ownable, ReentrancyGuard{
    uint24 constant fee = 3000;
    int24 tickSpacing;

    Token mToken;
    RewardToken rToken;
    IWETH9 WETH;

    INonfungiblePositionManager v3Manager;
    ISwapRouter v3Router;
    IUniswapV3Factory v3Factory;
    IUniswapV3Pool v3Pool;

    constructor(
      address _factoryAddr,
      address _routerAddr,
      address _managerAddr
    ) {
      v3Factory = IUniswapV3Factory(_factoryAddr);
      v3Manager = INonfungiblePositionManager(_managerAddr);
      v3Router = ISwapRouter(_routerAddr);

      v3Pool = IUniswapV3Pool(v3Factory.createPool(address(mToken), address(WETH), fee));

      v3Pool.initialize(encodePriceSqrt(1, 1000));
      tickSpacing = v3Pool.tickSpacing();

      (, int24 curTick, , , , , ) = v3Pool.slot0();
      curTick = curTick - (curTick % tickSpacing);

      int24 lowerTick = curTick - (tickSpacing * 2);
      int24 upperTick = curTick + (tickSpacing * 2);

      mToken.approve(address(v3Manager), 1000e18);
      WETH.approve(address(v3Manager), 1e18);

      v3Manager.mint(
          INonfungiblePositionManager.MintParams({
              token0: v3Pool.token0(),
              token1: v3Pool.token1(),
              fee: fee,
              tickLower: lowerTick,
              tickUpper: upperTick,
              amount0Desired: 1000e18,
              amount1Desired: 1e18,
              amount0Min: 0e18,
              amount1Min: 0e18,
              recipient: msg.sender,
              deadline: block.timestamp
          })
      );
    }
}
