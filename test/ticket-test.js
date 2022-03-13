const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Ticket", function () {
  it("Should return the new ticket's params: campaignId, price, ", async function () {
    const Ticket = await ethers.getContractFactory("VelvetTicket");
    const ticket = await Ticket.deploy({
      price: 10,
      campaignId: 123,
    });
    await ticket.deployed();

    expect(await ticket.getCampaignId()).to.equal(123);
    expect(await ticket.getPrice()).to.equal(10);

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // // wait until the transaction is mined
    // await setGreetingTx.wait();
    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });

  it("Should have a price", async () => {
    const Ticket = await ethers.getContractFactory("VelvetTicket");
    const ticket = await Ticket.deploy({
      campaignId: 123,
      price: 10,
    });
    await ticket.deployed();
  });
});