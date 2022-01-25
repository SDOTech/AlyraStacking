// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SDOToken is ERC20 {

    address contractOwner; //define the owner


    constructor(address owner) ERC20("SDO Coin", "SDO") {
        contractOwner = owner;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function mint(address recipient, uint256 amount) external {
        require(msg.sender==contractOwner, "mint not allowed !");
        _mint(recipient, amount * 10**uint256(decimals()));
    }
}
