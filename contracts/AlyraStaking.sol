// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceConsumerV3.sol";
import "./SDOToken.sol";

// User cannot withdraw it's token before 1 year
// Rewards are percent (rateReward) of amount stacked
// Rewards are calculated if last staking is more than 1 day
contract AlyraStaking {
    
    // ========= Entities =========

    struct Token {
        address tokenAddress;
        uint256 stakedAmount;
        bool isUsed;
        uint256 lastTransactionDate;    
    }

    struct RewardInfo {
        uint amount;
        uint lastAmountClaimed;
    }

    // ========= constants =========

    // seconds in a day
    uint256 constant DAY = 60 * 60 * 24;

    // ========= Variables =========

    
    mapping(address => mapping(address => Token)) public _stakingUserBalance;//relation between user and adress-token and amount
    mapping(address => address[]) _userToTokenAddress; //define a relation between a user and its token
    mapping(address => RewardInfo) _rewardAmount;

    //Rewards variables
    uint256 daysBeforewithdrawAllowed = 1; //cannot withdraw before 1 day
    uint256 rateReward = 10; //reward is 10% of stacked amount
    SDOToken private _SDOInstance = new SDOToken(address(this));//the reward token

    //Oracle init
    PriceConsumerV3 private priceConsumerV3 = new PriceConsumerV3();

    // ========= Constructor =========
    constructor() {
        
    }

    // ========= Events =========
    event TokenStaked(address tokenAddress, uint256 amount);
    event TokenWithdrawn(address tokenAddress, uint256 amount);
    event RewardsClaimed(uint256 amount);

    // =============================== Functions ===============================

      /// @notice Compute reward for user
    function computeReward(address userAddress) private {

        //get all token staked by user
        address[] memory userTokenAddresses = _userToTokenAddress[userAddress];
        
        //loop on each user token to compute rewards
        for(uint i = 0; i<userTokenAddresses.length;i++){
            computeRewardForToken(userAddress, userTokenAddresses[i]);
        }
    }

    /// @notice Compute reward for specific token and store it on main reward mapping
    /// @param userAddress user Address
    /// @param tokenAddress token address
    function computeRewardForToken(address userAddress, address tokenAddress)
        public
        returns (uint256)
    {
        uint256 reward = 0;
        uint256 daysCount = 0;
        Token memory currentToken = _stakingUserBalance[userAddress][tokenAddress];

        if (block.timestamp - currentToken.lastTransactionDate > DAY) {
            daysCount =  (block.timestamp - currentToken.lastTransactionDate) /60/60/24;
            reward = (currentToken.stakedAmount * rateReward) * daysCount; // cannnot store decimal, so ui need divide by 100 the result !
            
            //check if user already claimed
            uint amountAlreadyClaimed = _rewardAmount[userAddress].lastAmountClaimed;

            if(amountAlreadyClaimed>0){
                _rewardAmount[userAddress] = RewardInfo(reward-amountAlreadyClaimed,amountAlreadyClaimed);}
                else{

                    RewardInfo memory RewInf = RewardInfo(reward,block.timestamp) ; 
                    _rewardAmount[userAddress] = RewInf;
                }
        }


        return _rewardAmount[userAddress].amount;    
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
        computeRewardForToken(msg.sender, tokenAddress);

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

        //compute reward
        computeRewardForToken(msg.sender, tokenAddress);
    }

    /// @notice transfert rewards
    function ClaimRewards() public {
        
        //compute if rewrds available now
        computeReward(msg.sender);
        require(_rewardAmount[msg.sender].amount>0 ,"No Reward to claim !");
        
        uint amountToClaim = _rewardAmount[msg.sender].amount;
       
       // MINT      
       _SDOInstance.mint(msg.sender,amountToClaim);

       //update
       _rewardAmount[msg.sender].lastAmountClaimed = amountToClaim;

        emit RewardsClaimed(amountToClaim);
    }

    // ********************* Functions for DAPP *********************

    /// @notice return the total stake reward price
    /// @return an uint
    function getTokensRewards(address userAddress)
        public
        //view
        returns (uint256)
    { 
        computeReward(userAddress);
        return _rewardAmount[userAddress].amount;
    }

    /// @notice Return address of RewardToken
    function getSDOTokenAddress() public view returns (address) {
        return address(_SDOInstance);
    }

    /// @notice Return list of user's tokens staked on contract
    function getStakedTokens() public view returns (address[] memory) {
        return _userToTokenAddress[msg.sender];
    }

    /// @notice return the corresponding Rinkeby chainlink price for a token
    /// @dev note: for test purpose it also returns 10 for AT1 and 20 for AT2 tokens
    /// @param tokenAddress address of the staked token
    /// @return an uint
    function getTokenPrice(address tokenAddress) public view returns (int256) {
        try priceConsumerV3.getLatestPrice(tokenAddress) returns (
            int256 price
        ) {
            return price;
        } catch {
            return 0;
        }
    }
}
