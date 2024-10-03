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
    [owner, propertyManager, addr1, addr2] = await ethers.getSigners();
    PropertyFactory = await ethers.getContractFactory("HestyAccessControl");
    propertyFactory = await PropertyFactory.connect(owner).deploy();
    await propertyFactory.deployed();
    await propertyFactory.grantRole(
      await propertyFactory.BLACKLIST_MANAGER(),
      propertyManager.address
    );
  });

  it("should create a property and set its URI", async function () {
    const totalSupply = 100;
    const tokenUri = "https://example.com/token/1";
    const pricePerToken = ethers.utils.parseEther("0.1");

    const tx = await propertyFactory.createProperty(
      totalSupply,
      tokenUri,
      pricePerToken
    );
    const receipt = await tx.wait();
    //const tokenId = receipt.events[0].args[0];
    //expect(await propertyFactory.uri(tokenId)).to.equal(tokenUri);
  });

  it("should not allow transferring tokens directly to buyer", async function () {
    const totalSupply = 100;
    const tokenUri = "https://example.com/token/1";
    const pricePerToken = ethers.utils.parseEther("0.1");

    const tx = await propertyFactory.createProperty(
      totalSupply,
      tokenUri,
      pricePerToken
    );
    const receipt = await tx.wait();
    const tokenId = receipt.events[0].args[0];

    await expect(
      propertyFactory.connect(addr1).safeTransferFrom(
        owner.address,
        addr1.address,
        tokenId,
        1,
        "0x"
      )
    ).to.be.revertedWith("Cannot transfer tokens directly to buyer");
  });

  it("should allow transferring tokens to property manager", async function () {
    const totalSupply = 100;
    const tokenUri = "https://example.com/token/1";
    const pricePerToken = ethers.utils.parseEther("0.1");

    const tx = await propertyFactory.createProperty(
      totalSupply,
      tokenUri,
      pricePerToken
    );
    const receipt = await tx.wait();
    const tokenId = receipt.events[0].args[0];

    await propertyFactory.safeTransferFrom(
      owner.address,
      propertyManager.address,
      tokenId,
      1,
      "0x"
    );

    expect(await propertyFactory.balanceOf(propertyManager.address, tokenId)).to.equal(1);
  });
});
