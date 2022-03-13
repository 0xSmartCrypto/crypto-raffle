// Optional but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  // Deploy VelvetTicket
  const VelvetTicket = await hre.ethers.getContractFactory("VelvetTicket");
  const ticket = await VelvetTicket.deploy();
  await ticket.deployed();
  console.log("VelvetTicket deployed to:", ticket.address);

  // Make a raffle campaign
  const RaffleCampaign = await hre.ethers.getContractFactory("RaffleCampaign");
  /**
   *  string memory _raffleName, 
      string memory _influencer, 
      string memory _raffleDescription, 
      uint _ticketPrice, 
      uint _totalTickets, 
      uint _totalWinners, 
      address _ticketNFT
   */
  const raffleCampaign = await RaffleCampaign.deploy(
    "Raffle Campaign",
    "Influencer",
    "Raffle Campaign Description",
    100,
    1000,
    2,
    ticket.address
  );
  await raffleCampaign.deployed();
  console.log("RaffleCampaign deployed: ", raffleCampaign.address);
}

// Use async/await everywhere and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
