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

    Wich is the place where smart contract codes are placed.
    Apart from smart contracts