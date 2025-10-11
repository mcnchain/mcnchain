const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MCNMultiSig", () => {
  let multisig, owner, signer1, signer2, recipient;

  before(async () => {
    [owner, signer1, signer2, recipient] = await ethers.getSigners();
    const MultiSig = await ethers.getContractFactory("MCNMultiSig");
    multisig = await MultiSig.deploy([signer1.address, signer2.address], 2);
    await multisig.waitForDeployment();
  });

  it("should submit transaction", async () => {
    const tx = await multisig.submitTransaction(recipient.address, 0, "0x");
    await tx.wait();
    const stored = await multisig.transactions(0);
    expect(stored.destination).to.equal(recipient.address);
  });

  it("should confirm transaction by multiple signers", async () => {
    await multisig.connect(signer1).confirmTransaction(0);
    await multisig.connect(signer2).confirmTransaction(0);
    const tx = await multisig.transactions(0);
    expect(tx.executed).to.equal(true);
  });
});
