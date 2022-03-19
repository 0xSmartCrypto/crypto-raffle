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

# Deploy locally

1. Clone this repo and install dependencies with `npm install`
2. Make a copy of `.env.sample` and rename it to `.env`, fill in the required values (see below)
3. Edit `scripts/run.js` to your liking
4. Run `npm run dev`

# Running tests

1. Edit `test/raffle-test.js` and `test/ticket-test.js` to your liking
2. Run `npx hardhat test`

# Configuring .env

Must have:

`OWNER_PRIVATE_KEY`, `PERSON1_PRIVATE_KEY`, `PERSON2_PRIVATE_KEY`: these are the private keys of EOA accounts you can export using this [Metamask tutorial](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key)

For Rinkeby:

`RINKEBY_HTTPS_URL`: the URL of your Rinkeby testnet node from Infura, Alchemy, or any other compatible solution (e.g. `https://rinkeby.infura.io/v3/<your-infura-project-id>` or `https://eth-rinkeby.alchemyapi.io/v2/<your-alchemy-project-api-key>`)


# Deploying to Rinkeby

Run `npm run rinkeby`

As of writing of this README, the smart contracts were deployed to the Rinkeby testnet at:
- RaffleTicket deployed to: `0xc2b86849bdC94467DCd5a729E5c3C492539CeF4a`
- RaffleCampaign deployed to:  `0xD794e049e890b7d529FaB89B544F4cd5928d0581`


# TODO
  - [ ] Frontend
  - [ ] Abstract campaign so RaffleCampaign can be used on multiple raffles


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
