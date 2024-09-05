// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        require(msg.value > 0, "You need to send some Ether");
    }

    function withdraw(uint _amount) public {
        require(msg.sender == owner, "You are not the owner");
        require(address(this).balance >= _amount, "Not enough balance");
        payable(owner).transfer(_amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
