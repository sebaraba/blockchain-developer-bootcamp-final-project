## Bootcamp final project
### Install

Clone the project and install depedencies.

```bash

git clone https://github.com/sebaraba/blockchain-developer-bootcamp-final-project.git

cd blockchain-developer-bootcamp-final-project

yarn install

```
---

### Run

In order to run your application you'll have three terminals up for:

```bash
yarn start   (react app | spin up the frontend user facing side)
yarn chain   (hardhat backend | spin up )
yarn deploy  (to compile, deploy, and publish your contracts to the frontend)
```

> View your frontend at http://localhost:3000/

> Rerun `yarn deploy --reset` whenever you want to deploy new contracts to the frontend.

---

### Folder Structure

This repository is a monolit for a decentralised web application. 

The first folder we see is packages folder. We can find the two main sub-directories of the application in here:

1. Hardhat

    Wich is the place where smart contract codes are placed. Currently there are a total of two Smart contracts, namely: `Stake.sol` and `ExternalContract.sol`. Both of them have been written using solidity version `8.4.0`.

    Apart from smart contracts' code there are configurations for hardhat connection to different types of test net rpc nodes.

    Also in the package.json file we have defined a way to `deploy` your smart contract and run a local `chain` using `yarn`.

2. React-app

    That is the folder where the client side of the application resides. We have built a small scale react web application to connect to the local chain [for now, will be updated to connect to goerli in the following weeks]. 

    Using the deployment addresses of the two contracts and `react-hooks` in order to query the contract and transact with it.


## About

