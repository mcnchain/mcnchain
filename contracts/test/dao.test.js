const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MCNDAO", () => {
  let dao, token, owner, user;

  before(async () => {
    [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("VMCN");
    token = await Token.deploy();
    await token.waitForDeployment();

    const DAO = await ethers.getContractFactory("MCNDAO");
    dao = await DAO.deploy(token.target);
    await dao.waitForDeployment();

    await token.approve(dao.target, ethers.parseEther("100"));
  });

  it("should create a proposal", async () => {
    const tx = await dao.createProposal("Add new validator");
    await tx.wait();
    const proposal = await dao.proposals(0);
    expect(proposal.description).to.equal("Add new validator");
  });

  it("should allow voting", async () => {
    await dao.vote(0, true);
    const proposal = await dao.proposals(0);
    expect(proposal.votesFor).to.equal(1);
  });
});
