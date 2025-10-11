// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MCNMultiSig {
    address[] public owners;
    uint256 public requiredConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        require(_owners.length >= _requiredConfirmations, "Invalid number of owners/confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Zero address");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredConfirmations = _requiredConfirmations;
    }

    receive() external payable {}

    function submitTransaction(address to, uint256 value, bytes memory data) public onlyOwner {
        transactions.push(Transaction(to, value, data, false, 0));
    }

    function confirmTransaction(uint256 txIndex) public onlyOwner {
        require(txIndex < transactions.length, "Invalid tx index");
        require(!transactions[txIndex].executed, "Already executed");
        require(!confirmations[txIndex][msg.sender], "Already confirmed");

        confirmations[txIndex][msg.sender] = true;
        transactions[txIndex].confirmations++;

        if (transactions[txIndex].confirmations >= requiredConfirmations) {
            _executeTransaction(txIndex);
        }
    }

    function _executeTransaction(uint256 txIndex) internal {
        Transaction storage txn = transactions[txIndex];

        require(!txn.executed, "Already executed");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Execution failed");
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 txIndex) public view returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 confirmationsCount
    ) {
        Transaction storage txn = transactions[txIndex];
        return (txn.to, txn.value, txn.data, txn.executed, txn.confirmations);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }
}
