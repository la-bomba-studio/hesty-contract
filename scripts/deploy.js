const { ethers } = require('hardhat');

async function main() {

  let hestyAccessControl;
  let tokenFactory;
  let eurc;
  let referralSystem;
  let hestyRouter;

  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  console.log(owner.address)

  hestyAccessControl= await ethers.deployContract("HestyAccessControl", []);
  await hestyAccessControl.deployed();
  let vAddress0 = await hestyAccessControl.address;
  console.log("HestyAccessControl: " +  vAddress0)

  tokenFactory = await ethers.deployContract("TokenFactory", [300, 1000, 100, "0x168090283962c5129A2CBc91E099369297f32437", 1, vAddress0]);
  await tokenFactory.deployed();
  let vAddress = await tokenFactory.address;
  console.log("TokenFactory: " + vAddress)

  eurc = await ethers.deployContract("@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol:ERC20PresetMinterPauser", ["Euro Circle", "EURC"]);
  await eurc.deployed();
  let vAddress2 = await eurc.address;
  console.log("Euro Circle: " + vAddress2)

  referralSystem = await ethers.deployContract("ReferralSystem", [vAddress2, vAddress0, vAddress]);
  await referralSystem.deployed();
  let vAddress3 = await referralSystem.address;
  console.log("ReferralSystem: " + vAddress3)

  hestyRouter = await ethers.deployContract("HestyRouter", [vAddress, vAddress0]);
  await hestyRouter.deployed();
  let vAddress4 = await referralSystem.address;
  console.log("Hesty Router: " + vAddress4)

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
