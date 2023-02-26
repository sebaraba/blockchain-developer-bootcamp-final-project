// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ExternalContract is Ownable {

  bool internal locked;
  bool public completed;
  address private ownerAddres;
  uint256 public constant threshold = 1 ether;
  uint256 public cropDeadline = block.timestamp + 5 minutes;
  uint256 public balance = 0;
  uint256 public firstDownpayment = 0;
  uint256 public secondDownpayment = 0;
  uint256 public thirdDownpayment = 0;
  uint256 public finalPayment = 0;

  //Events
  event FundsWithdraw(address indexed sender, uint256 amount, string paymentBatch);
  event CompletedContract(uint256 totalBalance, uint256 firstDownpayment, uint256 secondDownpayment, uint256 thirdDownpayment, uint256 finalPayment);

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
    firstDownpayment = balance * 1/10;
    secondDownpayment = balance * 3/20;
    thirdDownpayment = balance * 1/4;
    finalPayment = balance * 1/2;
    emit CompletedContract(balance, firstDownpayment, secondDownpayment, thirdDownpayment, finalPayment);

    completed = true;
    return completed;
  }

  function retrieveFunds() public payable noReentrant() onlyOwner {
    uint256 currentTime = cropDeadline / 5;
    if (currentTime <= cropDeadline * 1/5) {
        payable(ownerAddres).transfer(firstDownpayment);
        emit FundsWithdraw(ownerAddres, firstDownpayment, 'FirstDownpayment');
        firstDownpayment = 0;
    }
    if (currentTime <= cropDeadline * 2/5 ) {
        uint256 totalAmount = firstDownpayment + secondDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        emit FundsWithdraw(ownerAddres, totalAmount, 'SecondDownpayment');
        secondDownpayment = 0;
    }
    if (currentTime <= cropDeadline * 4/5) {
        uint256 totalAmount = firstDownpayment + secondDownpayment + thirdDownpayment;
        payable(ownerAddres).transfer(totalAmount);
        emit FundsWithdraw(ownerAddres, totalAmount, 'ThirdDownpayment');
        thirdDownpayment = 0;
    }
    if (currentTime >= cropDeadline) {
        payable(ownerAddres).transfer(finalPayment);
        emit FundsWithdraw(ownerAddres, finalPayment, 'FinalPayment');
    }
  }

}
