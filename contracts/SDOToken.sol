// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SDOToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("SDO Stable Coin", "SDO") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
}
