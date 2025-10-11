const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MCNNFT", () => {
  let nft, owner, user;

  before(async () => {
    [owner, user] = await ethers.getSigners();
    const NFT = await ethers.getContractFactory("MCNNFT");
    nft = await NFT.deploy();
    await nft.waitForDeployment();
  });

  it("should mint NFT to user", async () => {
    await nft.safeMint(user.address, "ipfs://meta/1");
    expect(await nft.ownerOf(0)).to.equal(user.address);
  });

  it("should return tokenURI", async () => {
    const uri = await nft.tokenURI(0);
    expect(uri).to.equal("ipfs://meta/1");
  });
});
