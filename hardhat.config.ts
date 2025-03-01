import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();

const {PRIVATE_KEY, BASE_ETHERSCAN_API_KEY, BASE_SEPOLIA_RPC_URL} = process.env;
const config: HardhatUserConfig = {
  solidity: "0.8.28",

  networks: {
    base_sepolia: {
      url: BASE_SEPOLIA_RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    }
  },
  etherscan: {
    apiKey: BASE_ETHERSCAN_API_KEY,
  }
};

export default config;
