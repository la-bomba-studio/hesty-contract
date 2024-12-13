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
    tokenFactory = await TokenFactory.connect(owner).deploy(300, 100, owner.address, 1, hestyAccessControlCtr.address);
    await tokenFactory.deployed();

    Token = await ethers.getContractFactory("@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol:ERC20PresetMinterPauser");
    token = await Token.connect(owner).deploy("name", "symbol");
    await token.deployed()

    Referral = await ethers.getContractFactory("ReferralSystem");
    referral = await Referral.connect(owner).deploy(token.address, hestyAccessControlCtr.address, tokenFactory.address);
    await referral.deployed()
   // console.log("KYC Manager "+ await hestyAccessControlCtr.KYC_MANAGER())

    Issuance = await ethers.getContractFactory("HestyAssetIssuance");
    issuance = await Issuance.connect(owner).deploy(tokenFactory.address);
    await issuance.deployed()

    await hestyAccessControlCtr.grantRole(
      "0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949",

      addr2.address
    );
/*
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

    await expect(
      referral.addApprovedCtrs(addr4.address)
    ).to.be.revertedWith("Already Approved");

  });

  it("Remove Approved Contracts", async function () {

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

  describe("Add Rewards", function () {

    it("Add rewards new user", async function () {

      await expect(
        referral.addRewards(addr3.address, addr4.address, 0, 2000)
      ).to.be.revertedWith("Not Approved");

      await referral.addApprovedCtrs(owner.address)

      await referral.addRewards(addr3.address, addr4.address, 0, 2000);

    });

    it("Add globalrewards new user", async function () {

      await expect(
        referral.addGlobalRewards(addr2.address, 2000)
      ).to.be.revertedWith("Not Approved");

      await referral.addApprovedCtrs(owner.address)

      await token.mint(owner.address, 2000);

      await token.approve(referral.address, 2000);

      await referral.addGlobalRewards(addr3.address, 2000);

    });


    it("Claim globalrewards new user", async function () {
      await expect(
        referral.addGlobalRewards(addr2.address, 2000)
      ).to.be.revertedWith("Not Approved");

      await referral.addApprovedCtrs(owner.address)

      await token.mint(owner.address, 2000);

      await token.approve(referral.address, 2000);

      await referral.addGlobalRewards(addr3.address, 2000);

      await token.mint(referral.address, 2000)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await referral.claimGlobalRewards(addr3.address);

      expect(await referral.globalRewards(addr3.address)).to.equal(0);

    });

    it("Claim rewards new user", async function () {
      await expect(
        referral.addRewards(addr3.address, addr4.address, 0, 2000)
      ).to.be.revertedWith("Not Approved");

      await referral.addApprovedCtrs(owner.address)

      await token.mint(referral.address, 2000);

      await referral.addRewards(addr3.address, addr4.address, 0, 2000)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

     await  expect(
      referral.claimPropertyRewards(addr3.address, 0)
        ).to.be.revertedWith("Not yet");

      expect(await referral.rewards(addr3.address, 0)).to.equal(2000);

    });

    it("Add rewards Double", async function () {

      await expect(
        referral.addRewards(addr3.address, addr4.address, 0, 2000)
      ).to.be.revertedWith("Not Approved");

      await referral.addApprovedCtrs(owner.address)

      await token.mint(referral.address, 4000)

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

  describe("Admin Setters", function () {

    it("setHestyAccessControlCtr", async function () {

      await expect(
        referral.setHestyAccessControlCtr("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      await expect(
        referral.connect(addr4).setHestyAccessControlCtr(addr1.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        referral.setHestyAccessControlCtr(addr1.address)
      ).to.emit(referral, 'NewHestyAccessControl')
        .withArgs(addr1.address);
    });

    it("setNewTokenFactory", async function () {

      await expect(
        referral.setNewTokenFactory("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      await expect(
        referral.connect(addr4).setNewTokenFactory(addr1.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        referral.setNewTokenFactory(addr1.address)
      ).to.emit(referral, 'NewTokenFactory')
        .withArgs(addr1.address);
    });

  })

});
