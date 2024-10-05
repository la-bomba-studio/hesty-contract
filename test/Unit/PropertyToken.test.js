const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HestyAccessControl", function () {
  let PropertyFactory;
  let propertyFactory;
  let owner;
  let propertyManager;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, propertyManager, addr1, addr2, addr3] = await ethers.getSigners();
    HestyAccessControl = await ethers.getContractFactory("PropertyToken");
    hestyAccessControlCtr = await HestyAccessControl.connect(owner).deploy();
    await hestyAccessControlCtr.deployed();
    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.BLACKLIST_MANAGER(),
      addr1.address
    );

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.KYC_MANAGER(),
      addr2.address
    );

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.PAUSER_MANAGER(),
      addr3.address
    );
  });

  it("Get constants from Constants files ", async function () {

    expect(await hestyAccessControlCtr.BLACKLIST_MANAGER()).to.equal("0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b");

    expect(await hestyAccessControlCtr.FUNDS_MANAGER()).to.equal("0x93779bf6be703205517715c86297c193472c9d5533e90609b671022041168a4c");

    expect(await hestyAccessControlCtr.KYC_MANAGER()).to.equal("0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949");

    expect(await hestyAccessControlCtr.PAUSER_MANAGER()).to.equal("0x9ad250910475b46679c53074aa5d6cd2421e8c7126f9eb9c2d0aeeebbe1df64d");

    expect(await hestyAccessControlCtr.BASIS_POINTS()).to.equal(10_000);

    expect(await hestyAccessControlCtr.WAD()).to.equal(10 ** 6);

  });

  it("Only Admin", async function () {

    await hestyAccessControlCtr.onlyAdmin(owner.address);

    await expect(
      hestyAccessControlCtr.connect(propertyManager).onlyAdmin(propertyManager.address)
    ).to.be.revertedWith("Not Admin Manager");

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

  describe("Approve KYC and revert KYC Approval", function () {
    it("Approve KYC", async function () {

      await expect(
        hestyAccessControlCtr.approveUserKYC(addr2.address)
      ).to.be.revertedWith("Not KYC Manager");


      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await expect(
        hestyAccessControlCtr.connect(addr1).unBlacklistUser(propertyManager.address)
      ).to.be.revertedWith("Not blacklisted");

    });

    it("Approve KYC Twice", async function () {


      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await expect(
        hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)
      ).to.be.revertedWith("Already Approved");

    });

    it("Revert Kyc", async function () {


      await expect(
        hestyAccessControlCtr.connect(addr1).revertUserKYC(propertyManager.address)
      ).to.be.revertedWith("Not KYC Manager");

      await expect(
        hestyAccessControlCtr.connect(addr2).revertUserKYC(propertyManager.address)
      ).to.be.revertedWith("Not KYC Approved");

      await  hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await hestyAccessControlCtr.connect(addr2).revertUserKYC(propertyManager.address)

      expect(await hestyAccessControlCtr.kycCompleted(propertyManager.address)).to.equal(false);

    });

    it("Revert Kyc Twice", async function () {

      await  hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await hestyAccessControlCtr.connect(addr2).revertUserKYC(propertyManager.address)

      await expect(
        hestyAccessControlCtr.connect(addr2).revertUserKYC(propertyManager.address)
      ).to.be.revertedWith("Not KYC Approved");

    });

    it("Approve KYC, Revert Kyc and Approve KYC Again", async function () {

      await  hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await hestyAccessControlCtr.connect(addr2).revertUserKYC(propertyManager.address)

      await  hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)
    });

  })

  describe("Pause and Unpause", function () {


    it("Status at the Beginning of Hesty Control Pause", async function () {

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

    });

    it("Pause All Hesty Contracts", async function () {

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

      await hestyAccessControlCtr.connect(addr3).pause();

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

    });

    it("Pause All Hesty Contracts and then Unpause them", async function () {

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

      await hestyAccessControlCtr.connect(addr3).pause();

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

      await hestyAccessControlCtr.connect(addr3).unpause();

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

    });

    it("UnPause All Hesty Contracts when their are unpaused", async function () {

      await expect(
        hestyAccessControlCtr.connect(addr3).unpause()
      ).to.be.revertedWith("Pausable: not paused");


      expect(await hestyAccessControlCtr.paused()).to.equal(false);

    });

    it("Wrong Pauser Manager", async function () {

      await expect(
        hestyAccessControlCtr.connect(addr2).pause()
      ).to.be.revertedWith("Not Pauser Manager");

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

    });

    it("Wrong Pauser Manager for unpause", async function () {

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

      await hestyAccessControlCtr.connect(addr3).pause();

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

      await expect(
        hestyAccessControlCtr.connect(addr2).unpause()
      ).to.be.revertedWith("Not Pauser Manager");

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

    });

    it("Pause All Hesty Contracts, unpause and pause again", async function () {

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

      await hestyAccessControlCtr.connect(addr3).pause();

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

      await hestyAccessControlCtr.connect(addr3).unpause();

      expect(await hestyAccessControlCtr.paused()).to.equal(false);

      await hestyAccessControlCtr.connect(addr3).pause();

      expect(await hestyAccessControlCtr.paused()).to.equal(true);

    });

  });

});
