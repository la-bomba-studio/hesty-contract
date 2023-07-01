require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    polygon: {
      url: process.env.ALCHEMY_POLYGON_URL,
      accounts: [process.env.SIGNER_PRIV_KEY],
      gasPrice: 180000000000
    },
    polygonTestnet: {
      url: process.env.ALCHEMY_POLYGON_URL,
      accounts: [process.env.SIGNER_PRIV_KEY],
    },
    goerli: {
      url: process.env.ALCHEMY_GOERLI_URL,
      accounts: [process.env.SIGNER_PRIV_KEY],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
  mocha: {
    timeout: 21000000,
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
      polygonMumbai: process.env.POLYGON_API_KEY,
    },
  },
};
