const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Referral System", function () {
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

    Token = await ethers.getContractFactory("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20");
    token = await Token.connect(owner).deploy("name", "symbol");
    await token.deployed()

    Referral = await ethers.getContractFactory("ReferralSystem");
    referral = await Referral.connect(owner).deploy(token.address, hestyAccessControlCtr.address, tokenFactory.address);
    await token.deployed()

    /*
    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.KYC_MANAGER(),
      addr2.address
    );

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.PAUSER_MANAGER(),
      addr3.address
    );*/
  });


  it("Basic Getters", async function () {

    expect(await referral.ctrHestyControl()).to.equal(hestyAccessControlCtr.address);

    expect(await referral.rewardToken()).to.equal(token.address);

    expect(await referral.tokenFactory()).to.equal(tokenFactory.address);

  });

  it("Add Approved Contracts", async function () {

    await expect(
      referral.connect(addr3).addApprovedCtrs(addr4.address)
    ).to.be.revertedWith("Not Admin Manager");

    await referral.addApprovedCtrs(addr4.address)

    expect(await referral.approvedCtrs(addr4.address)).to.equal(true);

  });

  it("Remove Approved Contracts", async function () {

    await expect(
      referral.connect(addr3).addApprovedCtrs(addr4.address)
    ).to.be.revertedWith("Not Admin Manager");

    await referral.addApprovedCtrs(addr4.address)

    await referral.removeApprovedCtrs(addr4.address)

    expect(await referral.approvedCtrs(addr4.address)).to.equal(false);

  });

  describe("Add Rewards", function () {

    it("Add rewards new user", async function () {

      await expect(
        hestyAccessControlCtr.blacklistUser(addr2.address)
      ).to.be.revertedWith("Not Blacklist Manager");


      hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      referral.addRewards(addr3.address, addr4.address, 0, 2000);

    });

    it("Add globalrewards new user", async function () {


      await referral.addGlobalRewards(addr3.address, 2000);

    });


    it("Claim globalrewards new user", async function () {

      await referral.addGlobalRewards(addr3.address, 2000);

      await referral.claimGlobalRewards(addr3.address)

    });

    it("Add rewards Double", async function () {

      await expect(
        hestyAccessControlCtr.blacklistUser(addr2.address)
      ).to.be.revertedWith("Not Blacklist Manager");


      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await referral.addRewards(addr3.address, addr4.address, 0, 2000);
      await referral.addRewards(addr3.address, addr4.address, 0, 2000);


    });


  })

  describe("Setters", function () {

    it("setNewTokenFactory", async function () {

      await expect(
        referral.connect(addr3).setNewTokenFactory(propertyManager.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        referral.setNewTokenFactory("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      await referral.setNewTokenFactory(propertyManager.address)


    });

    it("setHestyAccessControlCtr", async function () {

      await expect(
        referral.connect(addr3).setHestyAccessControlCtr(propertyManager.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        referral.setHestyAccessControlCtr("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      referral.setHestyAccessControlCtr(propertyManager.address)


    });

    it("SetRewardToken", async function () {

      await expect(
        referral.connect(addr3).setRewardToken(propertyManager.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        referral.setRewardToken("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      referral.setRewardToken(propertyManager.address)


    });


  })

});
