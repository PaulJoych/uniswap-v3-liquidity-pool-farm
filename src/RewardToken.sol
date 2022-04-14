// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is Ownable, ERC20 {
    constructor() ERC20("Reward Token", "rTKN") {}

    function mint(address to_, uint256 amount_) external onlyOwner {
      _mint(to_, amount_);
    }

    function burn(address to_, uint256 amount_) external onlyOwner {
      _burn(to_, amount_);
    }
}