const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

    return { lock, unlockTime, lockedAmount, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

      expect(await lock.unlockTime()).to.equal(unlockTime);
    });

    it("Should set the right owner", async function () {
      const { lock, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await lock.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      const { lock, lockedAmount } = await loadFixture(
        deployOneYearLockFixture
      );

      expect(await ethers.provider.getBalance(lock.target)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest();
      const Lock = await ethers.getContractFactory("Lock");
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
});
const VestingContract = artifacts.require("VestingContract");
const MockToken = artifacts.require("MockToken");

contract("VestingContract", async (accounts) => {
  let vestingContract;
  let token;

  beforeEach(async () => {
    token = await MockToken.new();
    vestingContract = await VestingContract.new(
      token.address,
      accounts[1], // teamAddress
      accounts[2], // advisorAddress
      accounts[3], // privateInvestorAddress
      accounts[4], // seedInvestorAddress
      accounts[5]  // preSeedInvestorAddress
    );
  });

  it("should deploy and initialize correctly", async () => {
    assert.notEqual(vestingContract.address, "0x0", "Contract not deployed");
    assert.equal(await vestingContract.token(), token.address, "Token address not set correctly");
    assert.equal(await vestingContract.Owner(), accounts[0], "Owner address not set correctly");
  });

  it("should release team tokens correctly", async () => {
    // Advance time to reach the cliff
    await time.advanceBlockTo((await time.latestBlock()).toNumber() + time.duration.seconds(1));

    // Release team tokens
    await vestingContract.releaseTeamTokens({ from: accounts[1] });

    // Check the balance of the teamAddress
    const teamBalance = await token.balanceOf(accounts[1]);
    assert.equal(teamBalance.toString(), "15000000000000000000000000", "Team tokens not released correctly");
  });

  // Test other vesting schedules similarly...

  it("should not allow unauthorized addresses to release tokens", async () => {
    // Advance time to reach the cliff
    await time.advanceBlockTo((await time.latestBlock()).toNumber() + time.duration.seconds(1));

    // Attempt to release team tokens from an unauthorized address
    await truffleAssert.reverts(
      vestingContract.releaseTeamTokens({ from: accounts[2] }),
      "only Owner or Team wallet can send this call"
    );
  });

  it("should withdraw remaining tokens correctly", async () => {
    // Release all tokens
    await vestingContract.releaseTeamTokens({ from: accounts[1] });
    await vestingContract.releaseAdvisorsTokens({ from: accounts[2] });
    await vestingContract.releasePrivateInvestorsTokens({ from: accounts[3] });
    await vestingContract.releaseSeedInvestorsTokens({ from: accounts[4] });
    await vestingContract.releasePreSeedInvestorsTokens({ from: accounts[5] });

    // Withdraw remaining tokens
    await vestingContract.withdrawRemainingTokens({ from: accounts[0] });

    // Check the balance of the owner
    const ownerBalance = await token.balanceOf(accounts[0]);
    assert.equal(ownerBalance.toString(), "31250000000000000000000000", "Remaining tokens not withdrawn correctly");
  });
});
