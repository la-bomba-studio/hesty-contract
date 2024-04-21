require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
require('hardhat-abi-exporter');

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
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: "https://api-testnet.bscscan.com/api",
    },
  },
  abiExporter: {
    path: './data/abi',
    runOnCompile: true,
    clear: true
  },
};