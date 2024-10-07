const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Flow 1", function () {
  let PropertyFactory;
  let propertyFactory;
  let owner;
  let propertyManager;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, propertyManager, addr1, addr2, addr3, addr4] = await ethers.getSigners();

    HestyAccessControl = await ethers.getContractFactory("HestyAccessControl");
    hestyAccessControlCtr = await HestyAccessControl.connect(owner).deploy();
    await hestyAccessControlCtr.deployed();

    TokenFactory = await ethers.getContractFactory("TokenFactory");
    tokenFactory = await TokenFactory.connect(owner).deploy(300, 1000, 100, owner.address, 1, hestyAccessControlCtr.address);
    await tokenFactory.deployed();

    Token = await ethers.getContractFactory("@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol:ERC20PresetMinterPauser");
    token = await Token.connect(owner).deploy("name", "symbol");
    await token.deployed()

    Referral = await ethers.getContractFactory("ReferralSystem");
    referral = await Referral.connect(owner).deploy(token.address, hestyAccessControlCtr.address, tokenFactory.address);
    await referral.deployed()

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.KYC_MANAGER(),
      addr2.address
    );
    /*  await hestyAccessControlCtr.grantRole(
        await hestyAccessControlCtr.BLACKLIST_MANAGER(),
        addr1.address
      );

      await hestyAccessControlCtr.grantRole(
        await hestyAccessControlCtr.PAUSER_MANAGER(),
        addr3.address
      );*/
  });



  describe("Flow 1 Start", function () {
    beforeEach(async function () {

      await tokenFactory.initialize(referral.address)

    })

    it("Create Property, BuyTokens, DisttributeRevenue, claimProfits", async function () {

      await expect(
        referral.connect(addr3).addApprovedCtrs(addr4.address)
      ).to.be.revertedWith("Not Admin Manager");

      await referral.addApprovedCtrs(addr4.address)

      await referral.removeApprovedCtrs(addr4.address)

      expect(await referral.approvedCtrs(addr4.address)).to.equal(false);

      await expect(
        referral.removeApprovedCtrs(addr4.address)
      ).to.be.revertedWith("Not Approved Router");

    });

  })


});
