// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor(uint256 amount) ERC20("Dai", "DAI") {
        _mint(msg.sender, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function faucet(address recipient, uint256 amount) external {
        _mint(recipient, amount * 10**uint256(decimals()));
    }
}
