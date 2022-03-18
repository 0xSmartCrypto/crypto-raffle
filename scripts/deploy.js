// Optional but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  // 1. Deploy RaffleTicket
  const RaffleTicket = await hre.ethers.getContractFactory("RaffleTicket");
  const ticketContract = await RaffleTicket.deploy();
  await ticketContract.deployed();
  console.log("RaffleTicket deployed to:", ticketContract.address);

  // 2. Make a RaffleCampaign with RaffleTicket
  const RaffleCampaignContractFactory = await hre.ethers.getContractFactory(
    "RaffleCampaign"
  );
  const raffleCampaignContract = await RaffleCampaignContractFactory.deploy(
    // Raffle Name
    "Raffle Campaign",
    // Deadline of n blocks
    10,
    // Ticket Price
    hre.ethers.utils.parseEther("0.01"),
    // Total tickets available
    2,
    // Total 1 winner
    1,
    // NFT Ticket Contract address
    ticketContract.address
  );
  await raffleCampaignContract.deployed();
  console.log("RaffleCampaign deployed: ", raffleCampaignContract.address);
}

// Use async/await everywhere and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
