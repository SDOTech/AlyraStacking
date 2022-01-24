// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceConsumerV3.sol";

// User can withdraw it's token all the time
// Rewards are percent (rateReward) of amount stacked
// Rewards are calculated on each stacking but cannot be withdrawn before 1 day
contract AlyraStaking {
    //IERC20 SdoToken; // the reward token

    // ========= Entities =========

    struct Token {
        address tokenAddress;
        uint256 stakedAmount;
        bool isUsed;
        uint256 lastTransactionDate;
    }

    // ========= constants =========

    // seconds in a day
    uint256 constant DAY = 60 * 60 * 24;

    // ========= Variables =========

    //_stakingUserBalance between adress token and amount
    mapping(address => mapping(address => Token)) public _stakingUserBalance;
    mapping(address => address[]) _userToTokenAddress;
    mapping(address => uint256) _rewardAmount;

    //Rewards variables
    uint256 daysBeforewithdrawAllowed = 1; //cannot withdraw before 1 day
    uint256 rateReward = 10; //reward is 10% of stacked amount

    //Oracle init
    PriceConsumerV3 private priceConsumerV3 = new PriceConsumerV3();

    // ========= Constructor =========
    //constructor(address sdoAddress) {
    constructor() {
        //SdoToken = IERC20(sdoAddress);
    }

    // ========= Events =========
    event TokenStaked(address tokenAddress, uint256 amount);
    event TokenWithdrawn(address tokenAddress, uint256 amount);

    // =============================== Functions ===============================

    /// @notice Compute reward and store it
    /// @param userAddress user Address
    /// @param tokenAddress token address
    function computeReward(address userAddress, address tokenAddress)
        public
        returns (uint256)
    {
        uint256 reward = 0;
        Token memory currentToken = _stakingUserBalance[userAddress][
            tokenAddress
        ];

        if (block.timestamp - currentToken.lastTransactionDate > DAY) {
            //reward = currentToken.stakedAmount * (rateReward / 100);
            reward = currentToken.stakedAmount * rateReward; // cannnot store decimal, so ui need divide by 100 the result !  
            _rewardAmount[userAddress] = reward;
        }
        return _rewardAmount[userAddress];
    }

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

        //compute reward
        computeReward(msg.sender,tokenAddress);

        //fire event
        emit TokenStaked(tokenAddress, amount);

        return _stakingUserBalance[msg.sender][tokenAddress].stakedAmount;
    }

    /// @notice Get uer balance for specific ERC20Token
    /// @param userAddress address of the user
    /// @param tokenAddress address of the staked token
    function getUserBalance(address userAddress, address tokenAddress)
        public
        view
        returns (uint256)
    {
        return _stakingUserBalance[userAddress][tokenAddress].stakedAmount;
    }

    /// @notice  Get last stacking date  for specific ERC20Token
    /// @param userAddress address of the user
    /// @param tokenAddress address of the staked token
    function getLastTransactionDate(address userAddress, address tokenAddress)
        public
        view
        returns (uint256)
    {
        return
            _stakingUserBalance[userAddress][tokenAddress].lastTransactionDate;
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

    /// @notice factory to give chainlink data feed address for Rinkeby testnet
    /// @param sourceTokenSymbol symbol of the token
    /// @return an address
    function getDataFeedAddressToETH(string memory sourceTokenSymbol)
        private
        pure
        returns (address)
    {
        if (keccak256(bytes(sourceTokenSymbol)) == keccak256(bytes("DAI"))) {
            return address(0x74825DbC8BF76CC4e9494d0ecB210f676Efa001D);
        } else {
            return address(0);
        }
    }

    /// @notice return the corresponding Rinkeby chainlink price for a token
    /// @dev note: for test purpose it also returns 10 for AT1 and 20 for AT2 tokens
    /// @param tokenAddress address of the staked token
    /// @return an uint
    function getTokenPrice(address tokenAddress) public view returns (int256) {
        try ERC20(tokenAddress).symbol() returns (string memory tokenSymbol) {
            address datafeedAddress = getDataFeedAddressToETH(tokenSymbol);
            if (datafeedAddress == address(0)) {
                if (keccak256(bytes(tokenSymbol)) == keccak256(bytes("SDO"))) {
                    return 1;
                } else {
                    return 0;
                }
            } else {
                try priceConsumerV3.getLatestPrice(tokenAddress) returns (
                    int256 price
                ) {
                    return price;
                } catch {
                    return 0;
                }
            }
        } catch {
            return 0;
        }
    }

    // ********************* Functions for DAPP *********************

    /// @notice return the total stake reward price
    /// @return an uint
    function getTokensRewards(address userAddress, address tokenAddress)
        public
        view
        returns (uint256)
    {
        uint256 totalRewards;
        uint256 rewardAmount = _rewardAmount[userAddress];
        totalRewards += rewardAmount * uint256(getTokenPrice(tokenAddress));
        return totalRewards;
    }

    // /// @notice Return address of RewardToken
    // function getSDOTokenAddress() public view returns (address) {
    //     return address(SdoToken);
    // }

    /// @notice Return list of user's tokens staked on contract
    function getStakedTokens() public view returns (address[] memory) {
        return _userToTokenAddress[msg.sender];
    }
}
