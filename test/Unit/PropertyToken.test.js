const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Property Token", function () {
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

    PropertyToken = await ethers.getContractFactory("PropertyToken");
    propertyToken = await PropertyToken.connect(owner).deploy(owner.address, 10, "Token", "TKN", token.address, hestyAccessControlCtr.address);

    await propertyToken.deployed();

    await propertyToken.grantRole(
      await propertyToken.BLACKLIST_MANAGER(),
      addr1.address
    );

    await propertyToken.grantRole(
      await propertyToken.KYC_MANAGER(),
      addr2.address
    );

    await hestyAccessControlCtr.grantRole(
      await hestyAccessControlCtr.KYC_MANAGER(),
      addr2.address
    );

    await propertyToken.grantRole(
      await propertyToken.PAUSER_MANAGER(),
      addr3.address
    );
  });

  it("Get constants from Constants files ", async function () {

    expect(await propertyToken.BLACKLIST_MANAGER()).to.equal("0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b");

    expect(await propertyToken.FUNDS_MANAGER()).to.equal("0x93779bf6be703205517715c86297c193472c9d5533e90609b671022041168a4c");

    expect(await propertyToken.KYC_MANAGER()).to.equal("0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949");

    expect(await propertyToken.PAUSER_MANAGER()).to.equal("0x9ad250910475b46679c53074aa5d6cd2421e8c7126f9eb9c2d0aeeebbe1df64d");

  });

  it("Basic variables", async function () {

    expect(await propertyToken.rewardAsset()).to.equal(token.address);

    expect(await propertyToken.ctrHestyControl()).to.equal(hestyAccessControlCtr.address);

    expect(await propertyToken.dividendPerToken()).to.equal(0);

    expect(await propertyToken.xDividendPerToken(propertyManager.address)).to.equal(0);

    expect(await propertyToken.xDividendPerToken(addr4.address)).to.equal(0);


  });

  describe("Pause and Unpause", function () {


    it("Status at the Beginning of Hesty Control Pause", async function () {

      expect(await propertyToken.paused()).to.equal(false);

    });

    it("Pause Property Token", async function () {

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      expect(await propertyToken.paused()).to.equal(true);

    });

    it("Pause Property Token and then Unpause", async function () {

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      expect(await propertyToken.paused()).to.equal(true);

      await propertyToken.connect(addr3).unpause();

      expect(await propertyToken.paused()).to.equal(false);

    });

    it("UnPause Property Token when their are unpaused", async function () {

      await expect(
        propertyToken.connect(addr3).unpause()
      ).to.be.revertedWith("Pausable: not paused");


      expect(await propertyToken.paused()).to.equal(false);

    });

    it("Wrong Pauser Manager", async function () {

      await expect(
        propertyToken.connect(addr2).pause()
      ).to.be.revertedWith("Not Pauser");

      expect(await propertyToken.paused()).to.equal(false);

    });

    it("Wrong Pauser Manager for unpause", async function () {

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      expect(await propertyToken.paused()).to.equal(true);

      await expect(
        propertyToken.connect(addr2).unpause()
      ).to.be.revertedWith("Not Pauser");

      expect(await propertyToken.paused()).to.equal(true);

    });

    it("Pause Property Token, unpause and pause again", async function () {

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      expect(await propertyToken.paused()).to.equal(true);

      await propertyToken.connect(addr3).unpause();

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      expect(await propertyToken.paused()).to.equal(true);

    });

    it("Pause Property Token and try transfer", async function () {

      expect(await propertyToken.paused()).to.equal(false);

      await propertyToken.connect(addr3).pause();

      await expect(propertyToken.transfer(propertyManager.address, 10)
      ).to.be.revertedWith("No KYC Made");

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await expect(propertyToken.transfer(propertyManager.address, 10)
      ).to.be.revertedWith("ERC20Pausable: token transfer while paused");

      await propertyToken.connect(addr3).unpause();

      await expect(propertyToken.connect(addr4).transfer(propertyManager.address, 10),
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      await propertyToken.transfer(propertyManager.address, 10);

    });

  });


});
