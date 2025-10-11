const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("👤 Deployer:", deployer.address);

  const out = {};
  const save = (name, contract, args = []) => {
    out[name] = { address: contract.target, args };
  };

  // ==== Deploy ====
  const VMCN = await hre.ethers.deployContract("VMCN");
  await VMCN.waitForDeployment();
  console.log("✅ VMCN:", VMCN.target);
  save("VMCN", VMCN);

  const WrappedMCN = await hre.ethers.deployContract("WrappedMCN", [VMCN.target]);
  await WrappedMCN.waitForDeployment();
  console.log("✅ WrappedMCN:", WrappedMCN.target);
  save("WrappedMCN", WrappedMCN, [VMCN.target]);

  const Bridge = await hre.ethers.deployContract("Bridge", [VMCN.target, WrappedMCN.target]);
  await Bridge.waitForDeployment();
  console.log("✅ Bridge:", Bridge.target);
  save("Bridge", Bridge, [VMCN.target, WrappedMCN.target]);

  const MCNNFT = await hre.ethers.deployContract("MCNNFT");
  await MCNNFT.waitForDeployment();
  console.log("✅ MCNNFT:", MCNNFT.target);
  save("MCNNFT", MCNNFT);

  const MCNCollectibles = await hre.ethers.deployContract("MCNCollectibles");
  await MCNCollectibles.waitForDeployment();
  console.log("✅ MCNCollectibles:", MCNCollectibles.target);
  save("MCNCollectibles", MCNCollectibles);

  const MCNDAO = await hre.ethers.deployContract("MCNDAO", [VMCN.target]);
  await MCNDAO.waitForDeployment();
  console.log("✅ MCNDAO:", MCNDAO.target);
  save("MCNDAO", MCNDAO, [VMCN.target]);

  const MCNMultiSig = await hre.ethers.deployContract("MCNMultiSig");
  await MCNMultiSig.waitForDeployment();
  console.log("✅ MCNMultiSig:", MCNMultiSig.target);
  save("MCNMultiSig", MCNMultiSig);

  // ==== Save ====
  const dir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir);
  fs.writeFileSync(path.join(dir, "last.json"), JSON.stringify(out, null, 2));

  console.log("\n💾 Addresses saved to deployments/last.json");
}

main().catch(console.error);
