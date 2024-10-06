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

  it("Get constants from Constants files ", async function () {

    expect(await referral.BLACKLIST_MANAGER()).to.equal("0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b");

    expect(await referral.FUNDS_MANAGER()).to.equal("0x93779bf6be703205517715c86297c193472c9d5533e90609b671022041168a4c");

    expect(await referral.KYC_MANAGER()).to.equal("0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949");

    expect(await referral.PAUSER_MANAGER()).to.equal("0x9ad250910475b46679c53074aa5d6cd2421e8c7126f9eb9c2d0aeeebbe1df64d");


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

    expect(await referral.approvedCtrs(addr4.address)).to.equal(true);

  });

  describe("Blacklist and UnBlacklist", function () {

    it("Blacklist", async function () {

      await expect(
        hestyAccessControlCtr.blacklistUser(addr2.address)
      ).to.be.revertedWith("Not Blacklist Manager");


      hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)


    });

    it("Blacklist Twice", async function () {

      await expect(
        hestyAccessControlCtr.blacklistUser(addr2.address)
      ).to.be.revertedWith("Not Blacklist Manager");

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await expect(
        hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)
      ).to.be.revertedWith("Already blacklisted");

    });

    it("UnBlacklist ", async function () {

      await expect(
        hestyAccessControlCtr.unBlacklistUser(owner.address)
      ).to.be.revertedWith("Not Blacklist Manager");

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)


    });

    it("UnBlacklist Twice", async function () {

      await expect(
        hestyAccessControlCtr.unBlacklistUser(owner.address)
      ).to.be.revertedWith("Not Blacklist Manager");

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)

      await expect(
        hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)
      ).to.be.revertedWith("Not blacklisted");

    });

    it("Blacklist and UnBlacklist", async function () {

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)

    });

    it("Blacklist, UnBlacklist and Blacklist Again", async function () {

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

      await hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)

      await hestyAccessControlCtr.connect(addr1).blacklistUser(propertyManager.address)

    });

  })

});
