## Hesty Property and ITO Smart Contracts

***

#### Clone repository
```bash
git clone https://github.com/{REPO_URL}
```
```bash
git checkout development
```
***
#### Installation
```bash
cd hest-smart-contracts
npm install
```
***
#### Compile smart contracts
```bash
npx hardhat compile
```
***
#### Test smart contracts
```bash
npx hardhat test
```
***
#### Deployment
Create a .env file in the root directory and add the following variables
- ALCHEMY_POLYGON_URL = ""
- ALCHEMY_GOERLI_URL = ""
- ADMIN_WALLET_ADDRESS = ""
- SIGNER_PRIV_KEY = ""
- POLYGON_API_KEY = ""
- ETHERSCAN_API_KEY = ""

Supported networks for deployment
-   localhost
-   goerli
-   polygon (mumbai testnet)

##### Deploying Property Token Smart Contract
```bash
npx hardhat run --network polygonTestnet scripts/deploy-property-token.js
```
##### Deploying ITO Smart Contract
```bash
npx hardhat run --network polygonTestnet scripts/deploy-hesty-ito.js
```
***
#### Smart contract verfication
```bash
npx hardhat verify --network polygon DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1"
```