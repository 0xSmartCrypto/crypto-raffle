// eslint-disable-next-line no-unused-vars
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Ticket", function () {
  // it("Should return the new ticket's params: campaignId, price, ", async function () {
  //   const Ticket = await ethers.getContractFactory("RaffleTicket");
  //   const ticket = await Ticket.deploy({
  //     price: 10,
  //     campaignId: 123,
  //   });
  //   await ticket.deployed();

  //   expect(await ticket.getCampaignId()).to.equal(123);
  //   expect(await ticket.getPrice()).to.equal(10);
  //   assert.equal(1, 1);
  //   // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
  //   // // wait until the transaction is mined
  //   // await setGreetingTx.wait();
  //   // expect(await greeter.greet()).to.equal("Hola, mundo!");
  // });

  it("Should run", async () => {
    // const Ticket = await ethers.getContractFactory("RaffleTicket");
    // const ticket = await Ticket.deploy({
    //   campaignId: 123,
    //   price: 10,
    // });
    // await ticket.deployed();
    assert(ethers.BigNumber(2).isEqualTo(2));
  });
});
