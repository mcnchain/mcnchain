// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MCNDAO is Ownable {
    IERC20 public immutable VMCN;

    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed id, string description, uint256 deadline);
    event Voted(uint256 indexed id, address indexed voter, bool support, uint256 weight);
    event Executed(uint256 indexed id, bool passed);

    constructor(address tokenAddress) Ownable(msg.sender) {
        require(tokenAddress != address(0), "Zero token");
        VMCN = IERC20(tokenAddress);
    }

    function createProposal(string memory description, uint256 durationInSeconds) external onlyOwner {
        require(durationInSeconds > 0, "Bad duration");
        proposals.push(Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            deadline: block.timestamp + durationInSeconds,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, description, block.timestamp + durationInSeconds);
    }

    function vote(uint256 proposalId, bool support) external {
        require(proposalId < proposals.length, "Bad id");
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.deadline, "Voting ended");
        require(!hasVoted[msg.sender][proposalId], "Already voted");

        uint256 weight = VMCN.balanceOf(msg.sender);
        require(weight > 0, "No voting power");

        if (support) p.votesFor += weight;
        else p.votesAgainst += weight;

        hasVoted[msg.sender][proposalId] = true;
        emit Voted(proposalId, msg.sender, support, weight);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposals.length, "Bad id");
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.deadline, "Voting not ended");
        require(!p.executed, "Already executed");

        bool passed = p.votesFor > p.votesAgainst;
        p.executed = true;

        emit Executed(proposalId, passed);
        // при необходимости сюда добавляются реальные действия (вызовы/трансферы)
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }
}
