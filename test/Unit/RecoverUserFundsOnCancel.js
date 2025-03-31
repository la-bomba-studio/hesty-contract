const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RecoverUserFunds Unit Tests", function () {
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

    PropertyToken = await ethers.getContractFactory("PropertyToken");
    propertyToken = await PropertyToken.connect(owner).deploy(owner.address, 10, "Token", "TKN", token.address, hestyAccessControlCtr.address, owner.address);

    await propertyToken.deployed();

    // 1_000_000_000 it would mean a 1_000_000_000_000 total investment as ticker price is 1000€ min
    PropertyToken = await ethers.getContractFactory("PropertyToken");
    propertyToken2 = await PropertyToken.connect(owner).deploy(owner.address, 1_000_000_000, "Token", "TKN", token.address, hestyAccessControlCtr.address, owner.address);

    await propertyToken2.deployed();

    Issuance = await ethers.getContractFactory("HestyAssetIssuance");
    issuance = await Issuance.connect(owner).deploy(tokenFactory.address);
    await issuance.deployed()

    await propertyToken.grantRole(
      "0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b",
      addr1.address
    );

    await propertyToken.grantRole(
      "0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949",
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

  describe("DistributeRevenue and Claim it", function () {



    it("claimexternal", async function () {

      await token.mint(owner.address, 400000000);

      await token.approve(propertyToken.address, 2000000);

      await propertyToken.distributionRewards(2000000);

      expect(await token.balanceOf(owner.address)).to.equal(398000000);

      expect(await token.balanceOf(propertyToken.address)).to.equal(2000000);

      await propertyToken.claimDividensExternal(owner.address)

      expect(await propertyToken.dividendPerToken()).to.equal("20000000000000000000");

      expect(await token.balanceOf(propertyToken.address)).to.equal(0);

      expect(await token.balanceOf(owner.address)).to.equal(400000000);

    });

    it("claimexternalBigSupply", async function () {

      await token.mint(owner.address, 400000000);

      await token.approve(propertyToken2.address, 2000000);

      await propertyToken2.distributionRewards(2000000);

      expect(await token.balanceOf(owner.address)).to.equal(398000000);

      expect(await token.balanceOf(propertyToken2.address)).to.equal(2000000);

      await propertyToken2.claimDividensExternal(owner.address)

      expect(await propertyToken2.dividendPerToken()).to.equal(200000000000);

      expect(await token.balanceOf(propertyToken2.address)).to.equal(0);

      expect(await token.balanceOf(owner.address)).to.equal(400000000);

    });

  })

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
      ).to.be.revertedWith("Pausable: paused");

      await propertyToken.connect(addr3).unpause();

      await expect(propertyToken.connect(addr4).transfer(propertyManager.address, 10),
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      await propertyToken.transfer(propertyManager.address, 10);

    });

    it("Pause Property Token and try transferfrom", async function () {

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(addr3.address)

      await propertyToken.transfer(propertyManager.address, 1000);

      await propertyToken.connect(addr3).pause();

      await expect(propertyToken.transferFrom(propertyManager.address, addr3.address, 10)
      ).to.be.revertedWith("Pausable: paused");

      await propertyToken.connect(addr3).unpause();

      await expect(propertyToken.transferFrom(propertyManager.address, addr3.address, 10)
      ).to.be.revertedWith("ERC20: insufficient allowance");

      await propertyToken.connect(propertyManager).approve(owner.address, 10);



      await propertyToken.transferFrom(propertyManager.address, addr3.address, 10)


    });

  });


});
