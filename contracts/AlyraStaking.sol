// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceConsumerV3.sol";

contract AlyraStaking {
    IERC20 SdoToken; // the reward token

    // ========= Entities =========

    struct Token {
        address tokenAddress;
        uint256 stakedAmount;
        bool isUsed;
        uint256 lastTransactionDate;
    }

    // ========= Variables =========

    //_stakingUserBalance between adress token and amount
    mapping(address => mapping(address => Token)) public _stakingUserBalance;
    mapping(address => address[]) _userToTokenAddress;

    //Oracle init
    PriceConsumerV3 private priceConsumerV3 = new PriceConsumerV3();

    // ========= Constructor =========
    constructor(address sdoAddress) {
        SdoToken = IERC20(sdoAddress);
    }

    // ========= Events =========
    event TokenStaked(address tokenAddress, uint256 amount);
    event TokenWithdrawn(address tokenAddress, uint256 amount);

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

        //Add token if not exist on Smart Contract
        if (!_stakingUserBalance[msg.sender][tokenAddress].isUsed) {
            //Add
            _userToTokenAddress[msg.sender].push(tokenAddress);

            Token memory userToken = Token(
                tokenAddress,
                amount,
                true,
                block.timestamp
            );
            _stakingUserBalance[msg.sender][tokenAddress] = userToken;
        } else {
            //Update
            _stakingUserBalance[msg.sender][tokenAddress]
                .stakedAmount += amount;
        }

        // TODO : compute reward

        //fire event
        emit TokenStaked(tokenAddress, amount);

        return _stakingUserBalance[msg.sender][tokenAddress].stakedAmount;
    }

    /// @notice Stake an amount of a specific ERC20 token
    /// @param userAddress address of the user
    /// @param tokenAddress address of the staked token
    function getUserBalance(address userAddress, address tokenAddress)
        public
        view
        returns (uint256)
    {
        return _stakingUserBalance[userAddress][tokenAddress].stakedAmount;
    }

    /// @notice Withdraw an amount of a specific token
    /// @param tokenAddress address of the staked token
    /// @param amount amount to withdraw
    function withdrawTokens(address tokenAddress, uint256 amount) public {
        require(amount > 0, "You cannot withdraw 0 token !");
        require(
            _stakingUserBalance[msg.sender][tokenAddress].stakedAmount > 0,
            "This token never stacked on this contract !"
        );
        require(
            _stakingUserBalance[msg.sender][tokenAddress].stakedAmount >=
                amount,
            "Cannot withdraw an amount bigger than stacked !"
        );

        IERC20(tokenAddress).transfer(msg.sender, amount);

        _stakingUserBalance[msg.sender][tokenAddress].stakedAmount -= amount;
        _stakingUserBalance[msg.sender][tokenAddress]
            .lastTransactionDate = block.timestamp;

        //fire event
        emit TokenWithdrawn(tokenAddress, amount);
    }

    // ********************* Functions for DAPP *********************

    /// @notice Return address of RewardToken
    function getSDOTokenAddress() public view returns (address) {
        return address(SdoToken);
    }

    /// @notice Return list of user's tokens staked on contract
    function getStakedTokens() public view returns (address[] memory) {
        return _userToTokenAddress[msg.sender];
    }
}
