const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bridge", () => {
  let token, wrapped, bridge, owner, user;

  before(async () => {
    [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("VMCN");
    token = await Token.deploy();
    await token.waitForDeployment();

    const Wrapped = await ethers.getContractFactory("WrappedMCN");
    wrapped = await Wrapped.deploy(token.target);
    await wrapped.waitForDeployment();

    const Bridge = await ethers.getContractFactory("Bridge");
    bridge = await Bridge.deploy(token.target, wrapped.target);
    await bridge.waitForDeployment();

    await token.transfer(user.address, ethers.parseEther("100"));
  });

  it("should lock tokens", async () => {
    await token.connect(user).approve(bridge.target, ethers.parseEther("10"));
    await bridge.connect(user).lockTokens(ethers.parseEther("10"), user.address);
    const locked = await bridge.lockedAmount(user.address);
    expect(locked).to.equal(ethers.parseEther("10"));
  });
});
