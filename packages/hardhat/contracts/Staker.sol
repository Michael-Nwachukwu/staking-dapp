// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  uint256 public constant threshold = 1 ether;

  uint public deadline = block.timestamp + 80 hours;

  mapping ( address => uint256 ) public balances;
  
  event Stake(address from, uint256 value);

  modifier notCompleted {
    require(!exampleExternalContract.completed(), "ExampleExternalContract already completed");
    _;
  }

  function stake() public payable {

    require(msg.sender != address(0), "Address Zero not allowed");
    require(msg.value > 0, "Negative value not allowed");

    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);

  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

  function execute() public notCompleted {
    require(msg.sender != address(0), "Address Zero not allowed");
    require(block.timestamp >= deadline, "Deadline not reached");

    if (block.timestamp >= deadline && address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      withdraw();
    }
  }

  function withdraw() public {
    
    uint256 balance = balances[msg.sender];

    require(msg.sender != address(0), "Address Zero not allowed");
    require(address(this).balance >= balance, "Insufficient funds in contract");

    balances[msg.sender] = 0;

    (bool success,) = msg.sender.call{value: balance}("");

    require(success, "Failed withdrawal!");

  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint) {
    
    require(msg.sender != address(0), "Address Zero not allowed");
    uint timeleft;
    
    if (block.timestamp >= deadline) { 
      timeleft = 0;
    } else {
      timeleft = deadline - block.timestamp;
    }

    return timeleft;
    
  }

  receive() external payable {
    stake();
  }  

}
