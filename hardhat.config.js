const { task } = require("hardhat/config");

require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address, await account.getBalance());
  }
});

// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.3",
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts: [
        process.env.OWNER_PRIVATE_KEY,
        process.env.PERSON1_PRIVATE_KEY,
        process.env.PERSON2_PRIVATE_KEY,
      ],
    },
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts: [
        process.env.OWNER_PRIVATE_KEY,
        process.env.PERSON1_PRIVATE_KEY,
        process.env.PERSON2_PRIVATE_KEY,
      ],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  // etherscan: {
  //   apiKey: process.env.ETHERSCAN_API_KEY,
  // },
};
