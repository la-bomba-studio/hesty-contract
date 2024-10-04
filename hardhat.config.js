require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
require('hardhat-abi-exporter');
require('hardhat-contract-sizer');
require('solidity-coverage')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    mumbai: {
      url: "process.env.POLYGON_MUMBAI_RPC",
      accounts: [process.env.ROPSTEN_PRIVATE_KEY],
    },
    bscTestnet: {
      url: "https://bsc-testnet-rpc.publicnode.com",
      accounts: [process.env.ROPSTEN_PRIVATE_KEY],
      gasPrice: 3000000000,
    },
    baseSepolia: {
      url: "https://sepolia.base.org",
      accounts: [process.env.ROPSTEN_PRIVATE_KEY],
      gasPrice: 100000000,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: "VBJGC17JF227TPEH8FGS6BTZ1I6Q1UEX7W",
      baseSepolia: "empty"
    },
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://base-sepolia.blockscout.com/api",
          browserURL: "https://base-sepolia.blockscout.com"
        }
      }
    ]
  },
  abiExporter: {
    path: './data/abi',
    runOnCompile: true,
    clear: true
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: false
  }
};