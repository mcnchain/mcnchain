require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  networks: {
    /** ── MAINNET ───────────────────────────────────────────── */
    mcn: {
      url: "https://rpc.mcnchain.org",      // Mainnet RPC
      chainId: 2325,
      accounts: [process.env.PRIVATE_KEY || ""],
    },

    /** ── TESTNET ───────────────────────────────────────────── */
    mcntest: {
      url: "https://testnet-rpc.mcnchain.org",  // Testnet RPC
      chainId: 23251,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
  },

  etherscan: {
    apiKey: {
      mcn: process.env.ETHERSCAN_API_KEY || "",
      mcntest: process.env.ETHERSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "mcn",
        chainId: 2325,
        urls: {
          apiURL: "https://explorer.mcnchain.org/api",    // Blockscout API
          browserURL: "https://explorer.mcnchain.org",
        },
      },
      {
        network: "mcntest",
        chainId: 23251,
        urls: {
          apiURL: "https://testnet-explorer.mcnchain.org/api",
          browserURL: "https://testnet-explorer.mcnchain.org",
        },
      },
    ],
  },

  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
};
