// eslint-disable-next-line no-unused-vars
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

require("dotenv").config();

describe("RaffleCampaign", () => {
  let ticketContract;
  let raffleCampaignContract;
  let owner;
  let person1;
  let person2;
  let person3;
  let beneficiary;

  const raffleName = "Raffle Campaign";
  const deadline = 10;
  const ticketPrice = ethers.utils.parseEther("0.01");
  const totalTickets = 2;
  const totalWinners = 1;

  beforeEach(async () => {
    // eslint-disable-next-line no-unused-vars
    [owner, person1, person2, person3, beneficiary] = await ethers.getSigners();

    // Deploy RaffleTicket
    const RaffleTicketContractFactory = await ethers.getContractFactory(
      "RaffleTicket"
    );
    ticketContract = await RaffleTicketContractFactory.deploy();
    await ticketContract.deployed();

    // Deploy RaffleCampaign using RaffleTicket
    const RaffleCampaignContractFactory = await ethers.getContractFactory(
      "RaffleCampaign"
    );
    raffleCampaignContract = await RaffleCampaignContractFactory.deploy(
      raffleName,
      deadline,
      ticketPrice,
      totalTickets,
      totalWinners,
      ticketContract.address
    );
    await raffleCampaignContract.deployed();
  });

  describe("=== Deployment", async () => {
    it("Should deploy RaffleTicket and RaffleCampaign properly", async () => {
      console.log("Contract owner/deployer:", owner.address);
      console.log("RaffleTicket deployed to:", ticketContract.address);
      console.log("RaffleCampaign deployed: ", raffleCampaignContract.address);
    });

    it("Should have a campaign status of Active (0)", async () => {
      const state = await raffleCampaignContract.getCampaignState();
      expect(state).to.be.equal(0);
    });
  });

  describe("=== Minting", async () => {
    it("Should allow no more than 2 users to mint a ticket", async () => {
      const t1 = await raffleCampaignContract
        .connect(person1)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
      console.log(
        "Ticket minted: ",
        "https://rinkeby.etherscan.io/tx/" + t1.hash
      );

      const t2 = await raffleCampaignContract
        .connect(person2)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
      console.log(
        "Ticket minted: ",
        "https://rinkeby.etherscan.io/tx/" + t2.hash
      );

      await expect(
        raffleCampaignContract
          .connect(person3)
          .buyTicket({ value: ethers.utils.parseEther("0.01") })
      ).to.be.revertedWith("Campaign is not active.");
    });
  });

  describe("=== Picking winners", async () => {
    beforeEach(async () => {
      await raffleCampaignContract
        .connect(person1)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
      await raffleCampaignContract
        .connect(person2)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
    });

    it("Should have a campaign status of Closed (1)", async () => {
      const state = await raffleCampaignContract.getCampaignState();
      expect(state).to.be.equal(1);
    });

    it("Should let contract owner set winners", async () => {
      const winners = [2];
      await raffleCampaignContract.connect(owner).setWinners(winners);
      console.log("Winning numbers are: ", winners);
      expect(winners.length).to.be.equal(totalWinners);
    });
  });

  describe("=== Withdrawing funds", async () => {
    let beneficiaryBalanceBefore;
    let beneficiaryBalanceAfter;
    beforeEach(async () => {
      // Mint 2 tickets
      await raffleCampaignContract
        .connect(person1)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
      await raffleCampaignContract
        .connect(person2)
        .buyTicket({ value: ethers.utils.parseEther("0.01") });
      // Set winners
      const winners = [2];
      await raffleCampaignContract.connect(owner).setWinners(winners);
    });

    it("Should have a campaign status of WinnersSelected(2)", async () => {
      const state = await raffleCampaignContract.getCampaignState();
      console.log("campaign state: ", state);
      expect(state).to.equal(2);
    });

    it("Should show the proper contract balance", async () => {
      const expectedBalance = ticketPrice * totalTickets;
      const contractBalance = await raffleCampaignContract.getContractBalance();
      expect(contractBalance.toString()).to.equal(expectedBalance.toString());
    });

    it("Should only let contract owner withdraw funds", async () => {
      await expect(
        raffleCampaignContract.connect(owner).withdraw(beneficiary.address)
      ).to.be.ok;
      await expect(
        raffleCampaignContract.connect(person1).withdraw(beneficiary.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    before(async () => {
      // Get beneficiary balance before withdraw
      beneficiaryBalanceBefore = await beneficiary.getBalance();
    });
    it("Should check beneficiary to have proper amount of funds", async () => {
      // Now withdraw funds
      raffleCampaignContract.connect(owner).withdraw(beneficiary.address);

      // Now get balance after withdraw
      beneficiaryBalanceAfter = await beneficiary.getBalance();

      // Check if beneficiary balance is `revenue before withdraw`+ `revenue from withdraw`
      const revenue = ethers.BigNumber.from(ticketPrice).mul(totalTickets);
      const expectedBalance = beneficiaryBalanceBefore.add(revenue);
      expect(beneficiaryBalanceAfter).to.equal(expectedBalance);
    });

    it("Should check contract balance to be 0", async () => {
      // Now withdraw funds
      await raffleCampaignContract.connect(owner).withdraw(beneficiary.address);

      // Now get contract balance after withdraw
      expect(
        await raffleCampaignContract.connect(owner).getContractBalance()
      ).to.equal(0);
    });
  });
});
