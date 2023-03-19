// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./awardToken-Test.sol";

contract LiquidityMining {
    AwardToken public token;    // ERC-20 代币合约地址
    address public owner;   // 合约拥有者地址
    uint256 public rewardRate;  // 每秒钟发放的代币奖励数量
    uint256 public lastUpdateTime;  // 上一次更新时间
    uint256 public rewardPerTokenStored;  // 每个代币的奖励数量
    mapping(address => uint256) public userRewardPerTokenPaid;  // 每个用户已经获得的奖励数量
    mapping(address => uint256) public rewards;  // 每个用户已经获得的总奖励数量
    uint256 public totalSupply;  // 总流动性数量
    mapping(address => uint256) public balances;  // 每个用户的流动性数量
    mapping(address => mapping(address => uint256)) public allowance;  // 允许其他账户使用流动性的数量

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
    event LiquidityAdded(address indexed user, uint256 amount);
    event LiquidityRemoved(address indexed user, uint256 amount);

    constructor(AwardToken _token, uint256 _rewardRate) {
        token = _token;
        owner = msg.sender;
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    // 修改合约拥有者
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only the owner can transfer ownership");
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // 添加代币奖励
    function addReward(uint256 reward) external {
        require(msg.sender == owner, "Only the owner can add reward");
        require(reward > 0, "Invalid reward amount");
        token.transferFrom(msg.sender, address(this), reward);
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        emit RewardAdded(reward);
    }

    // 用户提取代币奖励
    function getReward() external {
        updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            token.transfer(msg.sender, reward);
           
        emit RewardPaid(msg.sender, reward);
        }
    }

    // 添加流动性
    function addLiquidity(uint256 amount) external {
        require(amount > 0, "Invalid liquidity amount");
        totalSupply += amount;
        balances[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
        updateReward(msg.sender);
        emit LiquidityAdded(msg.sender, amount);
    }

    // 移除流动性
    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "Invalid liquidity amount");
        require(balances[msg.sender] >= amount, "Insufficient liquidity balance");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        updateReward(msg.sender);
        emit LiquidityRemoved(msg.sender, amount);
    }

    // 更新用户奖励
    function updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    // 计算每个代币的奖励数量
    function rewardPerToken() internal view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        uint256 lastRewardTime = block.timestamp > lastUpdateTime ? block.timestamp : lastUpdateTime;
        return rewardPerTokenStored + ((lastRewardTime - lastUpdateTime) * rewardRate * 1e18 / totalSupply);
    }

    // 计算用户获得的奖励数量
    function earned(address account) internal view returns (uint256) {
        return balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
    }

}