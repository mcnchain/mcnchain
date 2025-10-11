const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // читаем файл с адресами, сохранённый после деплоя
  const file = path.join(__dirname, "../deployments/last.json");
  if (!fs.existsSync(file)) throw new Error("❌ Не найден файл deployments/last.json");

  const contracts = JSON.parse(fs.readFileSync(file, "utf8"));
  console.log("🔍 Starting verify...");

  for (const [name, addrData] of Object.entries(contracts)) {
    const address = addrData.address;
    const args = addrData.args || [];
    console.log(`\n🧩 Verifying ${name} @ ${address}`);

    try {
      await hre.run("verify:verify", {
        address,
        constructorArguments: args,
      });
      console.log(`✅ ${name} verified`);
    } catch (err) {
      if (err.message.includes("Already Verified")) {
        console.log(`⚠️ ${name} already verified`);
      } else {
        console.error(`❌ ${name} failed:`, err.message);
      }
    }
  }
}

main()
  .then(() => console.log("\n🚀 Verification finished"))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
