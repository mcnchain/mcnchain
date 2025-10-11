const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VMCN Token", () => {
  let token, owner, user;

  before(async () => {
    [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("VMCN");
    token = await Token.deploy();
    await token.waitForDeployment();
  });

  it("should mint initial supply to owner", async () => {
    const bal = await token.balanceOf(owner.address);
    expect(bal).to.be.gt(0);
  });

  it("should transfer tokens", async () => {
    const amount = ethers.parseEther("10");
    await token.transfer(user.address, amount);
    expect(await token.balanceOf(user.address)).to.equal(amount);
  });

  it("should burn tokens", async () => {
    const amount = ethers.parseEther("5");
    await token.connect(user).burn(amount);
    expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther("5"));
  });
});
