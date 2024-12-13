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
    tokenFactory = await TokenFactory.connect(owner).deploy(300, 100, owner.address, 1, hestyAccessControlCtr.address);
    await tokenFactory.deployed();

    Token = await ethers.getContractFactory("@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol:ERC20PresetMinterPauser");
    token = await Token.connect(owner).deploy("name", "symbol");
    await token.deployed()

    Referral = await ethers.getContractFactory("ReferralSystem");
    referral = await Referral.connect(owner).deploy(token.address, hestyAccessControlCtr.address, tokenFactory.address);
    await referral.deployed()

    Issuance = await ethers.getContractFactory("HestyAssetIssuance");
    issuance = await Issuance.connect(owner).deploy(tokenFactory.address);
    await issuance.deployed()

    await hestyAccessControlCtr.grantRole(
      "0x1df25ad963bcdf5796797f14b691a634f65032f90fca9c8f59fd3b590a07e949",
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
      tokenFactory.connect(propertyManager).initialize(referral.address, issuance.address)
    ).to.be.revertedWith("Not Admin Manager");

    expect(await tokenFactory.initialized()).to.equal(false);

    await tokenFactory.initialize(referral.address, issuance.address)

    expect(await tokenFactory.initialized()).to.equal(true);

  });




  describe("Non initialized contract Variable/Getters values", function () {

    it("ctrHestyControl, referralSystemCtr", async function () {

      expect(await tokenFactory.ctrHestyControl()).to.equal(hestyAccessControlCtr.address);
      expect(await tokenFactory.connect(addr2).ctrHestyControl()).to.equal(hestyAccessControlCtr.address);
      expect(await tokenFactory.connect(propertyManager).ctrHestyControl()).to.equal(hestyAccessControlCtr.address);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      expect(await tokenFactory.connect(propertyManager).referralSystemCtr()).to.equal(referral.address);

    });

    it("propertyCounter", async function () {

      expect(await tokenFactory.propertyCounter()).to.equal(0);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      expect(await tokenFactory.connect(addr2).propertyCounter()).to.equal(0);

    });

    it("minInvAmount", async function () {

      expect(await tokenFactory.minInvAmount()).to.equal(1);

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      expect(await tokenFactory.connect(addr2).minInvAmount()).to.equal(1);

    });

    it("Referral Related Variables", async function () {

      expect(await tokenFactory.maxNumberOfReferrals()).to.equal(20);
      expect(await tokenFactory.maxAmountOfRefRev()).to.equal(10000000000);

    });

    it("Treasury", async function () {

      expect(await tokenFactory.treasury()).to.equal(owner.address); //3%

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      expect(await tokenFactory.treasury()).to.equal(owner.address); //3%

    });

    it("Property", async function () {

      await tokenFactory.initialize(referral.address, issuance.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.addWhitelistedToken(token.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000, 1000, 4, 10000000,  token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

    });






  })

  describe("Buy Tokens", function () {

    it("Buy Tokens without referral", async function () {

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.addWhitelistedToken(token.address);

      await expect(
        issuance.createPropertyToken(1000000, token.address, "token", "TKN", hestyAccessControlCtr.address, addr1.address)
      ).to.be.revertedWith("Not TokenFactory");

      await tokenFactory.connect(propertyManager).createProperty(1000000,1000, 4, 10000000, token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

      await tokenFactory.approveProperty(0, 2937487238472834);

      // Approve owner kyc to allow him to buy property token
      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await token.approve(tokenFactory.address, 9);

      await token.mint(owner.address, 10000);

      await tokenFactory.buyTokens(owner.address,0, 2, "0x0000000000000000000000000000000000000000");


    });

    it("Buy Tokens with referral", async function () {

      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.addWhitelistedToken(token.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000,1000, 4, 10000000,  token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

      await tokenFactory.approveProperty(0, 2937487238472834);

      // Approve owner kyc to allow him to buy property token
      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await token.approve(tokenFactory.address, 9);

      await token.mint(owner.address, 10000);

      await tokenFactory.buyTokens(owner.address,0, 2, addr3.address);

    });
  })

  describe("Revenue Distribution", function () {
    beforeEach(async function () {
      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.addWhitelistedToken(token.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000, 1000, 4, 10000000,  token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

      await tokenFactory.approveProperty(0, 2937487238472834);

      // Approve owner kyc to allow him to buy property token
      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await token.approve(tokenFactory.address, 9);

      await token.mint(owner.address, 10000);

      await tokenFactory.buyTokens(owner.address,0, 2, addr3.address);
    })

    it("DistributeRevenue", async function () {

        await token.mint(addr4.address, 40000);

        await token.connect(addr4).approve(tokenFactory.address, 20002);

      await expect(
        tokenFactory.connect(addr4).distributeRevenue(0, 9999)
      ).to.be.revertedWith("Time not valid");



    });

    it("ClaimReturns", async function () {

      await expect(
        tokenFactory.connect(addr4).claimInvestmentReturns(addr4.address, 0)
    ).to.be.revertedWith("Time not valid");

    });

    it("recoverFundsInvested", async function () {

      await expect(
        tokenFactory.connect(addr4).recoverFundsInvested(addr4.address, 0)
    ).to.be.revertedWith("Time not valid");


    });

    it("extendRaiseForProperty", async function () {

      await expect(
        tokenFactory.connect(addr4).extendRaiseForProperty(0, 1000000000000)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.extendRaiseForProperty(0, 2937487238472824)
      ).to.be.revertedWith("Invalid deadline");

      await tokenFactory.extendRaiseForProperty(0, 2937487238472838)

      /*  await expect(
          tokenFactory.extendRaiseForProperty(10000000000000)
        ).to.emit(tokenFactory, 'NewMinInvestmentLimit')
          .withArgs(10000000000000);*/

    });

  })

  describe("ExtendRaise", function () {

    beforeEach(async function () {
      //Not yet initialized so therefore address(0)
      expect(await tokenFactory.referralSystemCtr()).to.equal("0x0000000000000000000000000000000000000000");

      await tokenFactory.initialize(referral.address, issuance.address)

      await hestyAccessControlCtr.connect(addr2).approveUserKYC(propertyManager.address);

      await tokenFactory.addWhitelistedToken(token.address);

      await tokenFactory.connect(propertyManager).createProperty(1000000,1000, 4, 10000000,  token.address, token.address, "token", "TKN", hestyAccessControlCtr.address)

      expect(await tokenFactory.propertyCounter()).to.equal(1);

      await tokenFactory.approveProperty(0, 2937487238472834);

      // Approve owner kyc to allow him to buy property token
      await hestyAccessControlCtr.connect(addr2).approveUserKYC(owner.address);

      await token.approve(tokenFactory.address, 9);

      await token.mint(owner.address, 10000);

      await tokenFactory.buyTokens(owner.address,0, 2, addr3.address);
    })

    it("recoverFundsInvested", async function () {
      await ethers.provider.send("evm_mine", [2937487238472844]);

      await tokenFactory.connect(addr4).recoverFundsInvested(addr4.address, 0)

        expect(await tokenFactory.isRefClaimable(0)).to.equal(false);


    })
  })

  describe("Admin Setters", function () {

    it("setOwnersFee", async function () {

      await expect(
        tokenFactory.connect(addr4).setOwnersFee(0, 1000)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setOwnersFee(0, 10000)
      ).to.be.revertedWith("Fee must be valid");

      await expect(
        tokenFactory.setOwnersFee(0, 1000)
      ).to.emit(tokenFactory, 'NewOwnersFee')
        .withArgs(0, 1000);

    })

    it("setPlatformFee", async function () {

      await expect(
        tokenFactory.connect(addr4).setPlatformFee(1000)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setPlatformFee(10000)
      ).to.be.revertedWith("Fee must be valid");

      await expect(
        tokenFactory.setPlatformFee(1000)
      ).to.emit(tokenFactory, 'NewPlatformFee')
        .withArgs(1000);


    });



    it("setMinInvAmount", async function () {

      await expect(
        tokenFactory.connect(addr4).setMinInvAmount(10000)
      ).to.be.revertedWith("Not Admin Manager");

    });

    it("setMaxNumberOfReferrals", async function () {

      await expect(
        tokenFactory.connect(addr4).setMaxNumberOfReferrals(10000)
      ).to.be.revertedWith("Not Admin Manager");

    });


    it("setMaxAmountOfRefRev", async function () {

      await expect(
        tokenFactory.connect(addr4).setMaxAmountOfRefRev(100000000)
      ).to.be.revertedWith("Not Admin Manager");


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

    it("setIssuanceContract", async function () {

      Issuance2 = await ethers.getContractFactory("HestyAssetIssuance");
      issuance2 = await Issuance2.connect(owner).deploy(tokenFactory.address);
      await issuance2.deployed()

      await expect(
        tokenFactory.setIssuanceContract("0x0000000000000000000000000000000000000000")
      ).to.be.revertedWith("Not allowed");

      await expect(
        tokenFactory.connect(addr4).setIssuanceContract(referral2.address)
      ).to.be.revertedWith("Not Admin Manager");

      await expect(
        tokenFactory.setIssuanceContract(referral2.address)
      ).to.emit(tokenFactory, 'NewIssuanceContract')
        .withArgs(referral2.address);

    });

  })

});
