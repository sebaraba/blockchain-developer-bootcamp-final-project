// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExternalContract.sol";

contract Staker {

  ExternalContract public externalContract;
  
  mapping(address => uint256) public balances;
  mapping(address => uint256) public depositTimestamps;

  uint256 public constant rewardRatePerBlock = 0.1 ether;
  uint256 public withdrawalDeadline = block.timestamp + 120 seconds;
  uint256 public claimDeadline = block.timestamp + 240 seconds;
  uint256 public currentBlock = 0;

  // Events
  event Stake(address indexed sender, uint256 amount);
  event Received(address, uint);
  event Execute(address indexed sender, uint256 amount);

  // Modifiers
  /*
    Checks if the withdrawal period has been reached or not
  */
  modifier withdrawalDeadlineReached( bool requiredReached ) {
    uint256 timeRemaining = withdrawalPeriodLeft();
    if( requiredReached ) {
      require(timeRemaining == 0, "Withdrawal period is not reached yet");
    } else {
      require(timeRemaining > 0, "Withdrawal period has been reached");
    }
    _;
  }

  /*
    Checks if the claim period has ended or not
  */
  modifier claimDeadlineReached( bool requiredReached ) {
    uint256 timeRemaining = claimPeriodLeft();
    if( requiredReached ) {
      require(timeRemaining == 0, "Claim period is not reached yet");
    } else {
      require(timeRemaining > 0, "Claim period has been reached");
    }
    _;
  }

  /*
    Requires that the contract only be completed once!
  */
  modifier notCompleted() {
    bool completed = externalContract.completed();
    require(!completed, "Stake already completed!");
    _;
  }
  
  constructor(address externalContractAddress) {
      externalContract = ExternalContract(externalContractAddress);
  }

  //Staking function responsible for staked ETH
  function stake() public payable withdrawalDeadlineReached(false) claimDeadlineReached(false) {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    depositTimestamps[msg.sender] = block.timestamp;
    emit Stake(msg.sender, msg.value);
  }

  /*
    Withdraw function for a user to remove their staked ETH inclusive
    of both principal and any accrued interest
  */
  function withdraw() public withdrawalDeadlineReached(true) claimDeadlineReached(false) notCompleted () {
    require(balances[msg.sender] > 0, "You have nothing to withdraw!");
    uint256 individualBalance = balances[msg.sender];
    uint256 individualBalancesRewards = individualBalance + ((block.timestamp - depositTimestamps[msg.sender]) * rewardRatePerBlock);
    balances[msg.sender] = 0;

    (bool sent, bytes memory data) = msg.sender.call{value: individualBalancesRewards}("");
    require(sent, "There was an error in the attempt to withdraw");
  }

  /*
    Allows any user to repatriate "unproductive" funds that are left in the staking contract
    past the defined withdrawal period
  */
  function execute() public claimDeadlineReached(true) notCompleted {
    uint256 contractBalance = address(this).balance;
    externalContract.complete{value: address(this).balance}();
  }

  /*
    READ-ONLY function to calculate the time remaining before the minimum staking period has passed
  */  
  function withdrawalPeriodLeft() public view returns(uint256 withdrawalTimeLeft) {
    if( block.timestamp >= withdrawalDeadline) {
      return(0);
    } else {
      return(withdrawalDeadline - block.timestamp);
    }
  }

  /*
    READ-ONLY function to calculate the time remaining before the minimum staking period has passed
  */
  function claimPeriodLeft() public view returns(uint256 claimTimeLeft) {
    if( block.timestamp >= claimDeadline) {
      return(0);
    } else {
      return(claimDeadline - block.timestamp);
    }
  }

  /*
  Time to "kill-time" on our local testnet
  */
  function killTime() public {
    currentBlock = block.timestamp;
  }

  /*
  \Function for our smart contract to receive ETH
  */
  receive() external payable {
      emit Received(msg.sender, msg.value);
  }
  
}
