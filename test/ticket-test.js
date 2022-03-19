// eslint-disable-next-line no-unused-vars
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Ticket", function () {
  it("should deploy locally to hardhat and have an address", async function () {
    const Ticket = await ethers.getContractFactory("RaffleTicket");
    const ticket = await Ticket.deploy({});
    await ticket.deployed();

    assert(ticket.address, "Ticket contract address is not defined");
  });
});
