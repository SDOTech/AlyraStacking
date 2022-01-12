// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceConsumerV3.sol";

contract AlyraDaiStaking {
    IERC20 SdoToken;

    // ========= Entities =========

    struct Token {
        address tokenAddress;
        uint256 stakedAmount;
        bool isUsed;
    }

    // ========= Variables =========

    //stakingSMBalance between adress token and amount
    mapping(address => Token) public stakingSMBalance;

    //stakingUserBalance between adress token and amount
    mapping(address => mapping(address => uint256)) public stakingUserBalance;

    //Oracle init
    PriceConsumerV3 private priceConsumerV3 = new PriceConsumerV3();

    // ========= Constructor =========
    constructor(address sdoAddress) {
        SdoToken = IERC20(sdoAddress);
    }

    // ========= Events =========
    event TokenStaked(address tokenAddress, uint256 amount);
    event TokenWithdraw(address tokenAddress, uint256 amount);

    // =============================== Functions ===============================

    /// @notice Stake an amount of a specific ERC20 token
    /// @param tokenAddress address of the staked token
    /// @param amount staked amount
    function stakeToken(address tokenAddress, uint256 amount) public {
        require(amount > 0, "You cannot stake 0 token");

        //Transfer amount to smartcontract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        //update SM balance
        if (stakingSMBalance[tokenAddress].isUsed) {
            stakingSMBalance[tokenAddress].stakedAmount += amount;
        } else {
            Token memory tokstaked = Token(tokenAddress, amount, true);
            stakingSMBalance[tokenAddress] = tokstaked;
        }

        // Update user balance for this token address
        if (stakingUserBalance[msg.sender][tokenAddress] > 0) {
            stakingUserBalance[msg.sender][tokenAddress] += amount;
        } else {
            stakingUserBalance[msg.sender][tokenAddress] = amount;
        }

        //fire event
        emit TokenStaked(tokenAddress, amount);
    }

    /// @notice Withdraw an amount of a specific ERC20 token
    /// @param tokenAddress address of the staked token
    /// @param amount amount to be withdrawn
    function withdrawToken(address tokenAddress, uint256 amount) public {
        require(amount > 0, "You cannot withdraw 0 token");
        require(stakingSMBalance[tokenAddress].isUsed, "Token not allowed");
        require(
            stakingSMBalance[tokenAddress].stakedAmount - amount > 0,
            "Not enough funds in SM"
        );
        require(
            stakingUserBalance[msg.sender][tokenAddress] > amount,
            "not enough funds"
        );

        // transfer amount back to stakeholder
        IERC20(tokenAddress).transfer(msg.sender, amount);

        // update SM balance
        stakingSMBalance[tokenAddress].stakedAmount -= amount;

        //update user balance
        stakingUserBalance[msg.sender][tokenAddress] -= amount;

        //fire event
        emit TokenStaked(tokenAddress, amount);
    }

    // ********************* Functions for DAPP *********************
    //TODO
    function getSDOTokenAddress() public view returns (address) {
        return address(SdoToken);
    }
}
