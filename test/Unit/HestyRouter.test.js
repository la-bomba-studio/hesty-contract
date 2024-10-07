const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Hesty Router", function () {
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

    Router = await ethers.getContractFactory("HestyRouter");
    router = await Router.connect(owner).deploy(tokenFactory.address, hestyAccessControlCtr.address);
    await router.deployed()

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.KYC_MANAGER(),
      addr2.address
    );

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.FUNDS_MANAGER(),
      router.address
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

  it("Get constants from Constants files ", async function () {

    expect(await tokenFactory.BLACKLIST_MANAGER()).to.equal("0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b");

    expect(await tokenFactory.FUNDS_MANAGER()).to.equal("0x93779bf6be703205517715c86297c193472c9d5533e90609b671022041168a4c");

    expect(await tokenFactory.KYC_MANAGER()).to.equal("0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949");

    expect(await tokenFactory.PAUSER_MANAGER()).to.equal("0x9ad250910475b46679c53074aa5d6cd2421e8c7126f9eb9c2d0aeeebbe1df64d");


  });


  describe("Admin Distribution", function () {

    beforeEach(async function () {
      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000, 4, 10000000, 0, token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

      await tokenFactory.approveProperty(0, 2937487238472834);

      // Approve owner kyc to allow him to buy property token
      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await token.approve(tokenFactory.address, 9);

      await token.mint(owner.address, 10000);

      await tokenFactory.buyTokens(owner.address, 0, 2, addr3.address);
    })

    it("adminDistribution", async function () {

      await expect(
        router.connect(addr4).adminDistribution(0, 20320)
      ).to.be.revertedWith("Not Admin Manager");

      await hestyAccessControlCtr.connect(addr2).approveKYCOnly(router.address);

      await expect(
        router.adminDistribution(0, 20320)
    ).to.be.revertedWith("Time not valid");

      await token.mint(router.address, 20320)

      expect(await token.balanceOf(router.address)).to.equal(20320);

    });

    it("offChainBuyTokens", async function () {

      await expect(
        router.connect(addr4).offChainBuyTokens(0, addr1.address, 20000)
      ).to.be.revertedWith("Not Admin Manager");

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(addr1.address);

      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore.timestamp;
      await expect(
        router.offChainBuyTokens(0, addr1.address, 20000)
      ).to.emit(tokenFactory, 'NewInvestment')
        .withArgs(0, addr1.address, 80000, timestampBefore + 1);
    });


  })

  describe("Admin Setters", function () {

    it("setHestyAccessControlCtr", async function () {

      await expect(
        router.setHestyAccessControlCtr("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      await expect(
        router.connect(addr4).setHestyAccessControlCtr(addr1.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        router.setHestyAccessControlCtr(addr1.address)
      ).to.emit(router, 'NewHestyAccessControl')
        .withArgs(addr1.address);
    });

    it("setNewTokenFactory", async function () {

      await expect(
        router.setNewTokenFactory("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not null");

      await expect(
        router.connect(addr4).setNewTokenFactory(addr1.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        router.setNewTokenFactory(addr1.address)
      ).to.emit(router, 'NewTokenFactory')
        .withArgs(addr1.address);
    });

  })

});
