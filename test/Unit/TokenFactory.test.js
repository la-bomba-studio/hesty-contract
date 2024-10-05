const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token Factory", function () {
  let PropertyFactory;
  let propertyFactory;
  let owner;
  let propertyManager;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, propertyManager, addr1, addr2, addr3] = await ethers.getSigners();

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

  it("Get constants from Constants files ", async function () {

    expect(await tokenFactory.BLACKLIST_MANAGER()).to.equal("0x46a5e99059e0b949704bc0cc0e3748d22c5f6ededc6f4a64b1e645b926d1163b");

    expect(await tokenFactory.FUNDS_MANAGER()).to.equal("0x93779bf6be703205517715c86297c193472c9d5533e90609b671022041168a4c");

    expect(await tokenFactory.KYC_MANAGER()).to.equal("0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949");

    expect(await tokenFactory.PAUSER_MANAGER()).to.equal("0x9ad250910475b46679c53074aa5d6cd2421e8c7126f9eb9c2d0aeeebbe1df64d");


  });

  it("Initialize", async function () {

    expect(await tokenFactory.initialized()).to.equal(false);

    await expect(
      tokenFactory.connect(propertyManager).initialize(referral.address)
    ).to.be.revertedWith("Not Admin Manager");

    expect(await tokenFactory.initialized()).to.equal(false);

    await tokenFactory.initialize(referral.address)

    expect(await tokenFactory.initialized()).to.equal(true);

  });

  it("Initialize", async function () {

    expect(await tokenFactory.initialized()).to.equal(false);

    await expect(
      tokenFactory.connect(propertyManager).initialize(referral.address)
    ).to.be.revertedWith("Not Admin Manager");

    expect(await tokenFactory.initialized()).to.equal(false);

    await tokenFactory.initialize(referral.address)

    expect(await tokenFactory.initialized()).to.equal(true);

  });

  describe("Non initialized contract Variable/Getters values", function () {

    it("ctrHestyControl, referralSystemCtr", async function () {

      expect(await tokenFactory.ctrHestyControl()).to.equal(hestyAccessControlCtr.address);
      expect(await tokenFactory.connect(addr2).ctrHestyControl()).to.equal(hestyAccessControlCtr.address);
      expect(await tokenFactory.connect(propertyManager).ctrHestyControl()).to.equal(hestyAccessControlCtr.address);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address)

      expect(await tokenFactory.connect(propertyManager).referralSystemCtr()).to.equal(referral.address);

    });

    it("propertyCounter", async function () {

      expect(await tokenFactory.propertyCounter()).to.equal(0);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address)

      expect(await tokenFactory.connect(addr2).propertyCounter()).to.equal(0);

    });

    it("minInvAmount", async function () {

      expect(await tokenFactory.minInvAmount()).to.equal(1);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address)

      expect(await tokenFactory.connect(addr2).minInvAmount()).to.equal(1);

    });

    it("Referral Related Variables", async function () {

      expect(await tokenFactory.maxNumberOfReferrals()).to.equal(20);
      expect(await tokenFactory.maxAmountOfRefRev()).to.equal(10000000000);
      expect(await tokenFactory.REF_FEE_BASIS_POINTS()).to.equal(100); // 1%

    });

    it("Treasury", async function () {

      expect(await tokenFactory.treasury()).to.equal(owner.address); //3%

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address)

      expect(await tokenFactory.treasury()).to.equal(owner.address); //3%

    });

    it("Property", async function () {

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000, 4, 10000000, 0, token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

    });


  })


});
