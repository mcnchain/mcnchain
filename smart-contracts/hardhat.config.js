require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  networks: {
     mcn: {
      url: "https://rpc.mcnchain.org", // RPC URL for MCN_Chain network
      chainId: 2325,
      accounts: [process.env.PRIVATE_KEY || ""]
    }
  },
  etherscan: {
    apiKey: {
      mcn: process.env.ETHERSCAN_API_KEY  || "" 
    },
    customChains: [
      {
        network: "mcn",
        chainId: 2325,
        urls: {
          apiURL: "https://explorer.mcnchain.org/api/",   // API Blockscout
          browserURL: "https://explorer.mcnchain.org"    // сам обозреватель
        }
      }
    ]
  },
  solidity: "0.8.24"
};



