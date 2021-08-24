# WKDT - Wakanda Token

## Introduction

This repository contains the smart contracts and transactions that implement
the core functionality of WKDT.

The smart contracts are written in Cadence, a new resource oriented
smart contract programming language designed for the Flow Blockchain.

### What is WKDT

WKDT is the function and governance token of wakanda ecology and community, and it is also used in the Wakanda metaverse.

### What is Flow?

Flow is a new blockchain for open worlds. Read more about it [here](https://www.onflow.org/).

### What is Cadence?

Cadence is a new Resource-oriented programming language 
for developing smart contracts for the Flow Blockchain.
Read more about it [here](https://www.docs.onflow.org)

We recommend that anyone who is reading this should have already
completed the [Cadence Tutorials](https://docs.onflow.org/cadence) 
so they can build a basic understanding of the programming language.

Resource-oriented programming, and by extension Cadence, 
is the perfect programming environment for Non-Fungible Tokens (NFTs), because users are able
to store their NFT objects directly in their accounts and transact
peer-to-peer.

### Contributing

If you see an issue with the code for the contracts, the transactions, scripts,
documentation, or anything else, please do not hesitate to make an issue or
a pull request with your desired changes. This is an open source project
and we welcome all assistance from the community!

## WKDT Contract Addresses

`WakandaToken.cdc`:0xbe4bac9b9b682df9
`WakandaPass.cdc`:0xbe4bac9b9b682df9
`WakandaProfile.cdc`:0xbe4bac9b9b682df9
`WakandaStorefront`:0xbe4bac9b9b682df9

### Non Fungible Token Standard

The WKDT contracts utilize the [Flow NFT standard](https://github.com/onflow/flow-nft)
which is equivalent to ERC-721 or ERC-1155 on Ethereum. If you want to build an NFT contract,
please familiarize yourself with the Flow NFT standard before starting and make sure you utilize it 
in your project in order to be interoperable with other tokens and contracts that implement the standard.

## Directory Structure

The directories here are organized into contracts, scripts, and transactions.

Contracts contain the source code for the WKDT contracts that are deployed to Flow.

Scripts contain read-only transactions to get information about
the state of someones Collection or about the state of the WKDT contract.

Transactions contain the transactions that various admins and users can use
to perform actions in the smart contract like creating plays and sets,
minting Moments, and transfering Moments.

 - `contracts/` : Where the WKDT related smart contracts live.
 - `transactions/` : This directory contains all the transactions and scripts
 that are associated with the WKDT smart contracts.
 - `transactions/scripts/`  : This contains all the read-only Cadence scripts 
 that are used to read information from the smart contract
 or from a resource in account storage.
 - `lib/` : This directory contains packages for specific programming languages
 to be able to read copies of the WKDT smart contracts, transaction templates,
 and scripts. Also contains automated tests written in those languages. Currently,
 Go is the only language that is supported, but we are hoping to add javascript
 and other languages soon. See the README in `lib/go/` for more information
 about how to use the Go packages.

## WKDT Contract Overview

```cadence

```


## How to Deploy and Test the WKDT Contract in VSCode

The first step for using any smart contract is deploying it to the blockchain,
or emulator in our case. Do these commands in vscode. 
See the [vscode extension instructions](https://docs.onflow.org/docs/visual-studio-code-extension) 
to learn how to use it.

 1. Start the emulator with the `Run emulator` vscode command.

This deploys the contract code. It also runs the contract's
`init` function, which initializes the contract storage variables,
stores the `Collection` and `Admin` resources 
in account storage, and creates links to the `Collection`.

As you can see, whenever we want to call a function, read a field,
or use a type that is defined in a smart contract, we simply import
that contract from the address it is defined in and then use the imported
contract to access those type definitions and fields.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.
If you are running these transactions manually in the Flow Playground or
vscode extension, you will need to remove the transaction arguments and
hard code the values that they are used for. 

You also need to replace the `ADDRESS` placeholders with the actual Flow 
addresses that you want to import from.

## How to run the automated tests for the contracts

See the `tests/` for instructions about how to run the automated tests.

## Instructions for creating Wakanda Pass


## License 
