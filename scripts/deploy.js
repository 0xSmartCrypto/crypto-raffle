// Optional but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  // 1. Deploy RaffleTicket
  const RaffleTicket = await hre.ethers.getContractFactory("RaffleTicket");
  const ticket = await RaffleTicket.deploy();
  await ticket.deployed();
  console.log("RaffleTicket deployed to:", ticket.address);

  // 2. Make a RaffleCampaign with RaffleTicket
  const RaffleCampaign = await hre.ethers.getContractFactory("RaffleCampaign");
  /**
    string memory _raffleName, 
    string memory _raffleDescription, 
    uint _deadlineInBlocks,
    uint _ticketPrice, 
    uint _totalTickets, 
    uint _totalWinners, 
    address _ticketNFT
   */
  const raffleCampaign = await RaffleCampaign.deploy(
    "Raffle Campaign",
    "Raffle Campaign Description",
    128, // 128 blocks
    100, // $100
    1000, // 1000 tickets
    1, // 2 winners
    ticket.address
  );
  await raffleCampaign.deployed();
  console.log("RaffleCampaign deployed: ", raffleCampaign.address);

  // 3. Mint ticket as user 1

  // 4. Mint ticket as user 2
  // 5. Set winners as manager
  // 6. Verify campaign states
}

// Use async/await everywhere and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
