// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExternalContract.sol";

/**
 * @author  Raba Sebastian
 * @title   Staker Contract
 * @notice  collects funds staked on the platform
 */
contract Staker {

  ExternalContract public externalContract;
  
  mapping(address => uint256) public balances;
  mapping(address => uint256) public depositTimestamps;
  uint256 public constant threshold = 1 ether;

  uint256 public constant rewardRatePerBlock = 0.1 ether;
  uint256 public withdrawalDeadline = block.timestamp + 30 seconds;
  uint256 public claimDeadline = block.timestamp + 60 seconds;
  uint256 public currentBlock = 0;

  // Events
  event Stake(address indexed sender, uint256 amount);
  event Received(address, uint);
  event Execute(address indexed sender, uint256 amount);

  // Modifiers
  /**
   * @dev     Checks if the withdrawal period has been reached or not
   * @param   requiredReached  bool
   */
  modifier withdrawalDeadlineReached( bool requiredReached ) {
    uint256 timeRemaining = withdrawalPeriodLeft();
    if( requiredReached ) {
      require(timeRemaining == 0, "Withdrawal period is not reached yet");
    }
    _;
  }

  /**
   * @dev     Checks if the claim period has ended or not
   * @param   requiredReached  bool
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

  /**
   * @dev     Requires that the contract only be completed once!
   */
  modifier notCompleted() {
    bool completed = externalContract.completed();
    require(!completed, "Stake already completed!");
    _;
  }

  /**
   * @dev     Checks arbitrary trashold has been reached
   */
  modifier tresholdReached() {
    bool treshHoldReached = address(this).balance > threshold;
    require(treshHoldReached, "Trashold not reached");
    _;
  }
  
  constructor(address externalContractAddress) {
      externalContract = ExternalContract(externalContractAddress);
  }

  /**
   * @dev     Staking function responsible for staked ETH
   */
  function stake() public payable withdrawalDeadlineReached(false) claimDeadlineReached(false) {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    depositTimestamps[msg.sender] = block.timestamp;
    emit Stake(msg.sender, msg.value);
  }

  /**
   * @dev     Withdraw function for a user to remove their staked ETH inclusive
              of both principal and any accrued interest
   */
  function withdraw() public withdrawalDeadlineReached(true) notCompleted () {
    require(balances[msg.sender] > 0, "You have nothing to withdraw!");
    uint256 individualBalance = balances[msg.sender];
    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value: individualBalance}("");
    require(sent, "There was an error in the attempt to withdraw");
  }

  /**
   * @dev     Allows any user to repatriate "unproductive" funds that are left in the staking contract
              past the defined withdrawal period
   */
  function execute() public claimDeadlineReached(true) notCompleted tresholdReached {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > threshold, "The expected amount of eth has not been raised!");
    
    externalContract.complete{value: address(this).balance}();
  }

  /**
   * @dev     Allows user to retrieve funds from external smart contract
   */
  function retrieve() public claimDeadlineReached(true) {
    externalContract.retrieveFunds();
  }
  
  /**
   * @dev     READ-ONLY function to calculate the time remaining before the minimum staking period has passed
   */
  function withdrawalPeriodLeft() public view returns(uint256 withdrawalTimeLeft) {
    if( block.timestamp >= withdrawalDeadline) {
      return(0);
    } else {
      return(withdrawalDeadline - block.timestamp);
    }
  }

  /**
   * @dev     READ-ONLY function to calculate the time remaining before the minimum staking period has passed
   */
  function claimPeriodLeft() public view returns(uint256 claimTimeLeft) {
    if( block.timestamp >= claimDeadline) {
      return(0);
    } else {
      return(claimDeadline - block.timestamp);
    }
  }

  /**
   * @dev     Time to "kill-time" on our local testnet
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
