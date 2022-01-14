// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceConsumerV3.sol";

contract AlyraStaking {
    IERC20 SdoToken;

    // ========= Entities =========

    struct Token {
        address tokenAddress;
        uint256 stakedAmount;
        uint256 lastTransactionDate;
    }

    // ========= Variables =========

    //stakingUserBalance between adress token and amount
    mapping(address => mapping(address => Token)) public stakingUserBalance;

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
    function stakeToken(address tokenAddress, uint256 amount)
        public
        returns (uint256)
    {
        require(amount > 0, "You cannot stake 0 token");

        //Transfer amount to smartcontract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        // TODO : compute reward

        if (stakingUserBalance[msg.sender][tokenAddress].stakedAmount == 0) {
            Token memory userToken = Token(
                tokenAddress,
                amount,
                block.timestamp
            );
            stakingUserBalance[msg.sender][tokenAddress] = userToken;
        } else {
            stakingUserBalance[msg.sender][tokenAddress].stakedAmount =
                stakingUserBalance[msg.sender][tokenAddress].stakedAmount +
                amount;
        }

        //fire event
        emit TokenStaked(tokenAddress, amount);

        return stakingUserBalance[msg.sender][tokenAddress].stakedAmount;
    }

    /// @notice Stake an amount of a specific ERC20 token
    /// @param userAddress address of the user
    /// @param tokenAddress address of the staked token
    function getUserBalance(address userAddress, address tokenAddress)
        public
        view
        returns (uint256)
    {
        return stakingUserBalance[userAddress][tokenAddress].stakedAmount;
    }

    // ********************* Functions for DAPP *********************

    function getSDOTokenAddress() public view returns (address) {
        return address(SdoToken);
    }

    // function getUserTokenAdresses(address owner)
    //     public
    //     view
    //     returns (address[] memory)
    // {
    //     //TODO
    // }

    // function getStackedToken(address tokenAddress, address owner)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     return stakingUserBalance[owner][tokenAddress];
    // }
}
