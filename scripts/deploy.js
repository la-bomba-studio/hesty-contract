const { ethers } = require('hardhat');

async function main() {
  // Deploy PropertyFactory contract
 /* const PropertyFactory = await ethers.getContractFactory('PropertyFactory');
  const propertyFactory = await PropertyFactory.deploy();

  await propertyFactory.deployed();

  console.log('PropertyFactory deployed to:', propertyFactory.address);

  // Call initialize function to set up contract roles and state variables
  await propertyFactory.initialize();

  console.log('Contract initialized successfully');*/


  let nest_nft;

  //Create USDC.E
  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  console.log(owner.address)

  nest_nft = await ethers.deployContract("TokenFactory", []);
  let vAddress = await nest_nft.getAddress();

  console.log("Stake NFT Address: " + vAddress)
  // console.log("USDC Token TX: " + tx + "block number" + blockNumber + "gas limit" + gasLimit + "gas Price" + gasPrice)
  await nest_nft.waitForDeployment();

  console.log("" +
    "                                        .####.########.\n" +
    "                                        ..##..##........\n" +
    "                                        ..##..##........\n" +
    "                                        ..##..#######....\n" +
    "                                        ..##.......##....\n" +
    "                                        ..##.......##....\n" +
    "                                        .####.#######.....\n" +
    "                                                                                                        \n" +
    "                                                                                                        \n" +
    "                          ##........####.##..........##.#########.\n" +
    "                         .##.........##...##........##..##........\n" +
    "                         .##.........##....##......##...##........\n" +
    "                         .##.........##.....##....##....#########.\n" +
    "                         .##.........##......##..##.....##........\n" +
    "                         .##.........##.......####......##........\n" +
    "                         .#########.####.......##.......#########.")

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
