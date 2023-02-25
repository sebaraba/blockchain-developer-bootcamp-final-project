Using information that I learned throughout the course and by documenting on several specific matters over the internet I chose to follow a series of security measures in order to avoid common attacks that could threat my smart contract.
Such measures are:
- using a specific compiler pragma -> I have used version number 0.8.4 to make sure I have a stable version of solidity that runs my contract and I don't use experimental functions;
- proper use of require -> in order to restrict certain transactions from executing if there are conditions that are not met;
- use modifiers only for validation -> I have used modifiers to add different condition checks in several methods of the smart contracts;
- no re-entrancy -> because I have an inter-contract communication enabled, I have used no re-entrancy to avoid contracts being able to run other transactions before the initial was not settled;