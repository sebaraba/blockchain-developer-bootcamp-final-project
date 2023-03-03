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

### I. Abstract

The abundance of distressful events that took place around the world in recent years have brought light to the fragile state our society’s peace and stable development. 
In the past 2 years we have witnessed a fierce full pandemic that has killed hundreds of thousands. We have seen war in Europe for the first time since the end of WWII. As well as we know we are running fast towards a global crisis that can span over a long period of time and sectors. 
Apart from the economic crisis that is due to come, there are a few other sectors that are not as well promoted, such as: energetic sector, food sector as well as clean water sector.
The subject of this writing will focus on the matter of the food crisis that I personally believe will unfortunately come as we proceed further into the near future. It is indeed a personal view, maybe a pessimistic one as well, but if we look around, we can spot various signs of it approaching.
Matters such as, global warming, war in Ukraine, economic crisis, sanitary crisis spanning over human, but animal health as well, pay all their part into an upcoming food crisis.
As history has taught as so far, after long social development, many consecutive years of economic growth and peace around the world, crisis come. But most importantly a big result of these crisis is usually a reform in the way we do things, and I would like to contribute to a solution to one of the problems that will haul food production.  
The subject of this project is composed of a system that comes as means of enhanced accessibility for people willing to support local producers of whole foods. All these by enabling them to contact local producers and seek for vegetables/fruits and meat they produce and commonly contribute to help finance their production process using a web application and blockchain infrastructure for payments and rights management.




### II. Problem definition

Starting from climate change implications the industrial agriculture process has and going down the route of extremely crowded supply chains, food waste problems and lack of raw materials, there are many failing points of the current industrial way of processing and distributing food around the world. 

Therefore, a reform is due to come, if we want to live sustainably with the lowest implications on the climate, but also consuming quality food and enabling the coming generations to thrive towards even more human society development.

This project’s aim is to bring to the table a means of accessibility to goods local producers provide to people living in their surroundings. A system where people can budge in and combine their monetary resources in order to enable local producers to sustain their whole agriculture activities throughout the year.

A big problem the locals currently face is that they cannot profit from economy of scale because of the small volume they produce. Currently small volume impacts profitability on two dimensions. 
First, the matter of production price per unit which is sensibly higher than what industrialized agriculture players can offer.  This drives key accounts attention away from trying to offer local products in the supermarkets. Also, it makes it hard for all types of consumers to have access to good quality products.
Secondly there is the problem of distribution. Often distribution costs can overtake the price per unit at the time distributors buy from producers. 
That is mainly because in order to fill a truck with any sorts of goods they would need to have many suppliers who are distributed across the region. So extra trips each truck needs to make to pick up the goods result in higher transportation costs per unit. 

On another note, the business model in agriculture is fairly old and can profit from the modern ways of cost sharing. That is because the amount of time that food needs in production phase is very long and costly at the same time. Currently when thinking of a local producer raising pork for example, we identify a production period of around 7 months. Months when the farmer needs to support all costs for food, health and accommodation of the animal. Eventually after 7 months they will sell the product, hopefully with profit, that is to be used to buy another batch of piglets and sustain their growth until the time they can be sold again. 

Considering the aforementioned problems, it is clear there is a lot of space to improve. Agriculture is a sector where informatics and technology didn’t yet boom, and I foresee a bright future in implementing digitalized solutions for food production and distribution. Just like we did with industrial production of clothes and shoes for example. 

### Implementation Details

In order to accommodate the aforementioned problem and address it's needs through an automated solution that works on a distributed ledger, I decided to encapsulate the business logic in a couple of smart contracts that run on Ethereum blockchain.
Ethereum is a decentralized, open-source blockchain with smart contract functionallity support. It runs with the native cryptocurrency called Ether.

Because the main bottlenack of the problem at hand is the lack of trust between the parties involed in a transaction. i.e:
    - The consumer does not trust the local producer to deliver the goods even though they payed a downpayment;
    - The local producer does not trust the customer to clear the last payment once the producer has delivered the goods;
I decided that a blockchain based solution could actually address this matter.

So in the current solution, we can find a couple of smart contracts that interact with each other:

#### 1. Staker.sol
Is a contract that the local producer would deploy. It is capable to accept an **arbitrary staking amount** of eth, that is retained by the contract until either:
- a fundraise completion deadline is reached -> in case the *trashold* value is reached the funds raised are moved into an external contract;
- a withdraw deadline is reached -> users cannot *withdraw* from the commitment of buying the goods they ordered anymore;
- a trashold is reached -> a trashold that the local producer sets, that would be the minimum amount for them to start the crop;
**These three parameters can be manually configured by the user of the contract before deployment.**

Then it offers the following main functionalities:
- withdraw() -> in case the deadline is not yet reached, a user that has stacked funds inside the contract, can still retrieve his/hers funds back;
- stake() -> any user can stake an arbitrary amount of eth before the completion deadline is reached;
- execute() -> that checks the trashold has been reached, if not it sends the funds back to the users that contributed, otherwise it transfers funds in a "vault" contract called the external contract;

Apart from these maine methods thare are other helper methods, modifiers and events that are used to check different conditions are met and to log transactions happening on the contract respectively. Some of the modifiers are:
- claimDeadlineReached -> checks if the deadline for the funds to be moved to the external contract is met;
- tresholdReached -> checks that the desired treshold has been met;

#### 2. ExternalCotnract.sol [*ownable* smart contract that extends open zeppelin standard]
Owner of this contract should always be the local producer, because retrieving funds from it are restrited to the owner only.
Is a contract that will recieve the funds gethered in the Staker.sol smart contract, and it is under the ownership of the local producer.
Using methods of this contract, the local producer will be able to retrieve downpayments that customers have payed, that are unlocked lineary based on the time that passed since the campain has started.

This contract offers two main functionallities:
- complete -> that is called by the staker contract in order to move funds to the external contract, when this method runs, it also initialisez constants corresponding to the amount of fudns to be unlocked at different times left until the end of the campaign;
- retrieveFunds -> that can only be called by the owner and based on the timestamp of the transaction an current block time, it computes the amount the producer should have.


## Deployed contracts:

Contracts have been deployed using Remix on Goerli network:
Staker.sol -> 0xD7D4F2FC3193E0D13Bc6E2C288A29d7D90aA5CC0
ExternalContract.sol -> 0x3e4a3e6c3b446fD7a59c3dAdc2ba0db9a80Fec62