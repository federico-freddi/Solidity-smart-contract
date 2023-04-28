// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Accounting{
    
    struct Transaction {
        uint amount;
        address sender;
        address receiver;
        uint timestamp;
        string description;
    }

    mapping(address => uint) public balances;
    Transaction[] public transactions;
    address public owner;

    event Deposit(address indexed account, uint amount);
    event Withdrawal(address indexed account, uint amount);
    event TransactionAdded( uint indexed id, uint amount, address indexed sender,
    address indexed receiver, uint timestamp, string description );

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can access to this function");
        _;
    }

    function deposit() public payable {
        require(msg.value >0, "Amount need to be greater than 0");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public payable{
        require(amount >0, "Amount need to be greater than 0");
        require(balances[msg.sender] > 0, "Nothing to withdraw");
        require(amount <= balances[msg.sender], "amount need to be <= your balances");
        balances[msg.sender] -= msg.value;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function transferValue(address receiver, uint amount, string memory description) public payable{
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        transactions.push(Transaction(amount, msg.sender, receiver, block.timestamp, description));

        emit TransactionAdded( transactions.length -1, amount, msg.sender,
    receiver, block.timestamp, description );

    }

    function getTransactionsCount() public view returns(uint) {
        return transactions.length;

    }

    function getTransactionByID(uint id) public view returns(uint, address, address, uint, string memory) {

        require( id < transactions.length, "invalid ID");
        Transaction memory transaction = transactions[id];

        return (transaction.amount, transaction.sender, transaction.receiver, transaction.timestamp, transaction.description);


    }

}