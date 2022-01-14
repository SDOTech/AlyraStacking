// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SDOToken is ERC20 {
    constructor() ERC20("SDO Stable Coin", "SDO") {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount * 10**uint256(decimals()));
    }
}
