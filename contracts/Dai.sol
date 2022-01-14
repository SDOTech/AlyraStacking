// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor(uint256 amount) ERC20("Dai Stable Coin", "Dai") {
        //_mint(msg.sender, amount);
        _mint(msg.sender, amount * 10**uint256(decimals()));
    }

    function faucet(address recipient, uint256 amount) external {
        _mint(recipient, amount * 10**uint256(decimals()));
    }
}
