// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author  Raba Sebastian
 * @title   ExternalContract
 * @dev     Used to store the funds after the kickstarter campaign is done and to retrieve funds by the owner only
 */

contract ExternalContract is Ownable {

  bool internal locked;
  bool public completed;
  address private ownerAddres;
  uint256 public constant threshold = 1 ether;
  uint256 public cropDeadline = block.timestamp + 10 minutes;
  uint256 public timeUnit = 2 minutes;
  uint256 public balance = 0;
  uint256 public firstDownpayment = 0;
  uint256 public secondDownpayment = 0;
  uint256 public thirdDownpayment = 0;
  uint256 public finalPayment = 0;

  uint256 public initialContractValue = 0;
  //Events
  event FundsWithdraw(
    address indexed sender,
    uint256 amount,
    string paymentBatch
    );
  event CompletedContract(
    uint256 totalBalance,
    uint256 firstDownpayment,
    uint256 secondDownpayment,
    uint256 thirdDownpayment,
    uint256 finalPayment
    );

  /**
   * @dev     Blocks a function to be called before it finishes executing
   */
  modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
  }

  constructor () {
    ownerAddres = msg.sender;
  }

  /**
   * @dev     Called for repatriating funds from Staker contract, it initialisez all values for 
   *          retrieving funds out of the contract
   */
  function complete() public payable noReentrant() returns(bool) {
    balance = balance + msg.value;
    initialContractValue = initialContractValue + msg.value;
    firstDownpayment = balance * 1/10;
    secondDownpayment = balance * 3/20;
    thirdDownpayment = balance * 1/4;
    finalPayment = balance * 1/2;
    emit CompletedContract(balance, firstDownpayment, secondDownpayment, thirdDownpayment, finalPayment);

    completed = true;
    return completed;
  }

  /**
   * @dev     Is used to retrieve money out of the smart contract by the owner of the cotnract.
   *          Who is the local producer in our case
   */
  function retrieveFunds() public payable noReentrant() onlyOwner {
    uint256 currentTime = block.timestamp;
    if (currentTime <= cropDeadline - timeUnit * 4 ) {
        payable(ownerAddres).transfer(firstDownpayment);
        balance = balance - firstDownpayment;
        firstDownpayment = 0;
        emit FundsWithdraw(ownerAddres, firstDownpayment, 'FirstDownpayment');
    } else if (currentTime <= cropDeadline - timeUnit * 2) {
        uint256 totalAmount = firstDownpayment + secondDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
        emit FundsWithdraw(ownerAddres, totalAmount, 'SecondDownpayment');
    } else if (currentTime <= cropDeadline - timeUnit) {
        uint256 totalAmount = firstDownpayment + secondDownpayment + thirdDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
        thirdDownpayment = 0;
        emit FundsWithdraw(ownerAddres, totalAmount, 'ThirdDownpayment');
    } else if (currentTime >= cropDeadline) {
        uint256 totalAmount = finalPayment + firstDownpayment + secondDownpayment + thirdDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
        thirdDownpayment = 0;
        finalPayment = 0;
        emit FundsWithdraw(ownerAddres, totalAmount, 'FinalPayment');
    }
  }
}
