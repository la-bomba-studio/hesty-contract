# Hesty PropertyFactory

PropertyFactory is a smart contract built on Polygon that allows users to create and manage digital properties. Each property is represented by an ERC1155 token, which can be purchased and owned by other users.

## Getting Started

To use PropertyFactory, you will need an Web3 wallet and some tokens to pay for transaction fees. You can interact with the contract using a tool like [Metamask](https://metamask.io/).

### Prerequisites

- Node.js v12.18.3 or later
- Hardhat v2.6.2 or later
- Ethers.js v5.4.5 or later
- Chai v4.3.4 or later
### Installation

1. Clone the repository: `git clone ${REPO_URL}`
2. Install dependencies: `npm install`
3. Compile the contracts: `npx hardhat compile`

## Usage

1. Deploy the contract: `npx hardhat run scripts/deploy.js --network polygon-mumbai`
2. Create a new property: `const tokenId = await propertyFactory.createProperty(totalSupply, tokenUri, pricePerToken)`
3. Transfer a property: `await propertyFactory.safeTransferFrom(fromAddress, toAddress, tokenId, amount, data)`
4. Check property details: `const property = await propertyFactory.properties(tokenId)`

## Testing

1. Run the tests: `npx hardhat test`

