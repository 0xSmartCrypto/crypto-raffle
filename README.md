# Crypto Raffle 

Crypto Raffle demonstrates the use of `RaffleTicket`, a ERC721 contract to encapsulate a raffle ticket, and `RaffleCampaign`, a contract to manage a raffle.

The raffle contract has the below features:
- A campaign manager can create a raffle, set the ticket price, and set a deadline when the raffle will end.
- The campaign manager can set up the raffle with one or more winners
- Participants can pay for a ticket in ETH and mint a ticket to the raffle in the `frontend`(#TBD)
- Participants can trade their tickets on OpenSea
- The campaign manager can select raffle winners by drawing verifiablly random numbers from ChainLink oracles
- Campaign states and selected are recorded on-chain
# Campaign 

A campaign has the states {`Active`, `Closed`, `WinnerSelected`}. It's `Active` when the raffle is created, `Closed` when the deadline is reached, and `WinnerSelected` when the winners are selected.

# TODO
  - [ ] Frontend
  - [ ] Abstract campaign so RaffleCampaign can be used on multiple raffles

# Smart Contract

The smart contract is deployed to the Rinkeby testnet at:

`<address>`




Below is the default documentation from the `Advanced Sample Hardhat Project` template.
# Advanced Sample Hardhat Project

This project demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
