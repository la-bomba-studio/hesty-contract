const { ethers } = require('hardhat');

async function main() {
  // Deploy PropertyFactory contract
  const PropertyFactory = await ethers.getContractFactory('PropertyFactory');
  const propertyFactory = await PropertyFactory.deploy();

  await propertyFactory.deployed();

  console.log('PropertyFactory deployed to:', propertyFactory.address);

  // Call initialize function to set up contract roles and state variables
  await propertyFactory.initialize();

  console.log('Contract initialized successfully');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
