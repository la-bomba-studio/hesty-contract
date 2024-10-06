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

  describe("Buy Tokens", function () {

    it("Buy Tokens without referral", async function () {

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

      await tokenFactory.buyTokens(0, 2, "0x0000000000000000000000000000000000000000");


    });

    it("Buy Tokens with referral", async function () {

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

      await tokenFactory.buyTokens(0, 2, addr3.address);

    });
  })

  describe("Revenue Distribution", function () {
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

      await tokenFactory.buyTokens(0, 2, addr3.address);
    })

    it("DistributeRevenue", async function () {

        await token.mint(addr4.address, 40000);

        await token.connect(addr4).approve(tokenFactory.address, 20002);

        await tokenFactory.connect(addr4).distributeRevenue(0, 10001);

      await expect(
        tokenFactory.connect(addr4).distributeRevenue(1, 10001)
      ).to.be.revertedWith("Id must be valid");

      await expect(
        tokenFactory.connect(addr4).distributeRevenue(0, 9999)
      ).to.be.revertedWith("Amount too low");

      await expect(
        tokenFactory.connect(addr4).distributeRevenue(0, 99999)
      ).to.be.revertedWith("ERC20: insufficient allowance");


    });

  })

  describe("Admin Setters", function () {

    it("setMaxNumberOfReferrals", async function () {

      await expect(
        tokenFactory.connect(addr4).setMaxNumberOfReferrals(10000)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setMaxNumberOfReferrals(100000)
      ).to.emit(tokenFactory, 'NewMaxNumberOfReferrals')
        .withArgs(100000);

    });


    it("setMaxAmountOfRefRev", async function () {

      await expect(
        tokenFactory.connect(addr4).setMaxAmountOfRefRev(100000000)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setMaxAmountOfRefRev(10000000)
      ).to.emit(tokenFactory, 'NewMaxAmountOfRefRev')
        .withArgs(10000000);

    });

    it("setTreasury", async function () {

      await expect(
        tokenFactory.setTreasury("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not allowed");

      await expect(
        tokenFactory.connect(addr4).setTreasury(addr1.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setTreasury(addr1.address)
      ).to.emit(tokenFactory, 'NewTreasury')
        .withArgs(addr1.address);

    });

    it("setReferralContract", async function () {

      Referral2 = await ethers.getContractFactory("ReferralSystem");
      referral2 = await Referral2.connect(owner).deploy(token.address, hestyAccessControlCtr.address, tokenFactory.address);
      await referral2.deployed()

      await expect(
        tokenFactory.setReferralContract("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not allowed");

      await expect(
        tokenFactory.connect(addr4).setReferralContract(referral2.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setReferralContract(referral2.address)
      ).to.emit(tokenFactory, 'NewReferralSystemCtr')
        .withArgs(referral2.address);

    });

  })

});
