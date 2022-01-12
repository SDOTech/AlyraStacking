// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor(uint256 amount) ERC20("Dai Stable Coin", "Dai") {
        _mint(msg.sender, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
}
