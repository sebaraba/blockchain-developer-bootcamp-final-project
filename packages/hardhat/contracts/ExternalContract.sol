// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

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

  modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
  }

  constructor () {
    ownerAddres = msg.sender;
  }

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

  function retrieveFunds() public payable noReentrant() {
    uint256 currentTime = block.timestamp;
    if (currentTime <= cropDeadline - timeUnit * 4 ) {
        emit FundsWithdraw(ownerAddres, firstDownpayment, 'FirstDownpayment');
        payable(ownerAddres).transfer(firstDownpayment);
        balance = balance - firstDownpayment;
        firstDownpayment = 0;
    } else if (currentTime <= cropDeadline - timeUnit * 2) {
        emit FundsWithdraw(ownerAddres, 1, 'SecondDownpayment');
        uint256 totalAmount = firstDownpayment + secondDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
    } else if (currentTime <= cropDeadline - timeUnit) {
        emit FundsWithdraw(ownerAddres, 2, 'ThirdDownpayment');
        uint256 totalAmount = firstDownpayment + secondDownpayment + thirdDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
        thirdDownpayment = 0;
    } else if (currentTime >= cropDeadline) {
        uint256 totalAmount = finalPayment + firstDownpayment + secondDownpayment + thirdDownpayment;
        emit FundsWithdraw(ownerAddres, totalAmount, 'FinalPayment');
        payable(ownerAddres).transfer(totalAmount);
        balance = balance - totalAmount;
        firstDownpayment = 0;
        secondDownpayment = 0;
        thirdDownpayment = 0;
        finalPayment = 0;
    }
  }
}
