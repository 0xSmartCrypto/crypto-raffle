// Optional but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

require("dotenv").config();

async function main() {
  // eslint-disable-next-line no-unused-vars
  const [owner, person1, person2, beneficiary] = await hre.ethers.getSigners();

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
  const raffleCampaignContract = await RaffleCampaignContractFactory.deploy(
    // Raffle Name
    "Raffle Campaign",
    // Deadline of n blocks
    2,
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
  let state = await raffleCampaignContract.getCampaignState();
  console.log(
    "RaffleCampaign deployed: ",
    raffleCampaignContract.address,
    ", state: ",
    state
  );

  // 3. Mint ticket as user 1
  const t1 = await raffleCampaignContract
    .connect(person1)
    .buyTicket({ value: hre.ethers.utils.parseEther("0.01") });
  console.log("Ticket minted: ", "https://rinkeby.etherscan.io/tx/" + t1.hash);

  // 4. Mint ticket as user 2
  const t2 = await raffleCampaignContract
    .connect(person2)
    .buyTicket({ value: hre.ethers.utils.parseEther("0.01") });
  console.log("Ticket minted: ", "https://rinkeby.etherscan.io/tx/" + t2.hash);

  // 5. Check campaign state:
  // should be 0 = Active (if not sold out)
  // should be 1 = Closed (if sold out)
  state = await raffleCampaignContract.getCampaignState();

  const totalTickets = await raffleCampaignContract.getTotalTickets();
  const ticketsBought = await raffleCampaignContract.getTicketsBought();
  console.log(
    "campaign state: ",
    state,
    "tickets bought",
    ticketsBought,
    "total tickets: ",
    totalTickets
  );

  // 6. Set winners as manager
  const winner = 2;
  await raffleCampaignContract.connect(owner).setWinners([winner]);
  console.log("Winning numbers are: ", [winner]);

  // 7. Check campaign state:
  // should be 2 = WinnersSelected
  state = await raffleCampaignContract.getCampaignState();
  console.log("campaign state: ", state);

  // 8. Check contract balance
  const balance = await raffleCampaignContract
    .connect(person1)
    .getContractBalance();
  console.log("Contract balance: ", hre.ethers.utils.formatEther(balance));

  // 9. Withdraw funds as owner to another address
  await raffleCampaignContract
    .connect(owner)
    // .withdraw(process.env.BENEFICIARY_ADDRESS_LOCAL);
    .withdraw(beneficiary.address);

  // 10. Check account balance
  const accountBalance = await beneficiary.getBalance();
  console.log(
    "Beneficiary account balance",
    hre.ethers.utils.formatEther(accountBalance)
  );
  // 11. Check contract balance
  const contractBalance = await raffleCampaignContract
    .connect(owner)
    .getContractBalance();
  console.log(
    "Contract balance: ",
    hre.ethers.utils.formatEther(contractBalance)
  );
}

// Use async/await everywhere and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
