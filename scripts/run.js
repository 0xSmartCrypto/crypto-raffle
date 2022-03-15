// Optional but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  const [owner, person1, person2] = await hre.ethers.getSigners();

  // 1. Deploy RaffleTicket
  const RaffleTicketContractFactory = await hre.ethers.getContractFactory(
    "RaffleTicket"
  );
  const ticketContract = await RaffleTicketContractFactory.deploy();
  await ticketContract.deployed();
  console.log("Contract owner/deployer:", owner.address);
  console.log("RaffleTicket deployed to:", ticketContract.address);

  // 2. Make a RaffleCampaign with RaffleTicket
  const RaffleCampaignContractFactory = await hre.ethers.getContractFactory(
    "RaffleCampaign"
  );
  /**
    string memory _raffleName, 
    string memory _raffleDescription, 
    uint _deadlineInBlocks,
    uint _ticketPrice, 
    uint _totalTickets, 
    uint _totalWinners, 
    address _ticketNFT
   */
  const raffleCampaignContract = await RaffleCampaignContractFactory.deploy(
    "Raffle Campaign",
    10, // 10 blocks
    hre.ethers.utils.parseEther("0.01"), // 0.01 ether
    2, // 2 tickets
    1, // 2 winners
    ticketContract.address
  );
  await raffleCampaignContract.deployed();
  let state = await raffleCampaignContract.getCampaignState();
  console.log(
    "RaffleCampaign deployed: ",
    raffleCampaignContract.address,
    ", state: ",
    state
  );

  // 3. Mint ticket as user 1
  await raffleCampaignContract
    .connect(person1)
    .buyTicket({ value: hre.ethers.utils.parseEther("0.01") });

  // 4. Mint ticket as user 2
  await raffleCampaignContract
    .connect(person2)
    .buyTicket({ value: hre.ethers.utils.parseEther("0.01") });

  // State should be Closed (sold out)
  state = await raffleCampaignContract.getCampaignState();
  console.log("campaign state: ", state);

  // 5. Set winners as manager

  // 6. Verify campaign states
  // 7. Withdraw funds as owner to another address
}

// Use async/await everywhere and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
