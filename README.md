# Platform-EVM-Dex-Contracts

## Overview

This repository contains two main components: **Core Contracts** and **Periphery**. Both components share a similar folder structure, with the Core Contracts housing essential smart contracts and the Periphery containing additional functionalities and tools to interact with the Core.

## Repository Folder Structure

### Core Contracts

The `Core Contracts` folder has the following architecture:

```
Core Contracts/
│
├── build/ # Build directory for compiled contracts
├── cache/ # Cache for build artifacts
├── contracts/ # Smart contracts
│
├── deploy/ # Deployment scripts
├── node_modules/ # Node.js packages
├── test/ # Test files
├── test/shared/ # deploymnet for test files
│
├── .env # Environment variables
├── .gitattributes # Git attributes
├── .gitignore # Files to ignore in Git
├── .mocharc.json # Mocha configuration
├── .prettierrc # Prettier configuration
├── .waffle.json # Waffle configuration
│
├── deployedAddress.js # Deployed contract addresses
├── hardhat.config.js # Hardhat configuration
├── LICENSE # License file
├── package.json # Node.js package configuration
├── README.md # This README file
├── tsconfig.json # TypeScript configuration
└── yarn.lock # Yarn lock file
```

### V2-Periphery

The `V2-Periphery` folder shares the same architecture:

```
V2-Periphery/
│
├── build/ # Build directory for compiled contracts
├── cache/ # Cache for build artifacts
├── contracts/ # Smart contracts
│
├── deploy/ # Deployment scripts
├── node_modules/ # Node.js packages
├── test/ # Test files
├──test/shared/ # deployment for test files
│
├── .env # Environment variables
├── .gitattributes # Git attributes
├── .gitignore # Files to ignore in Git
├── .mocharc.json # Mocha configuration
├── .prettierrc # Prettier configuration
├── .waffle.json # Waffle configuration
│
├── deployedAddress.js # Deployed contract addresses
├── hardhat.config.js # Hardhat configuration
├── LICENSE # License file
├── package.json # Node.js package configuration
├── tsconfig.json # TypeScript configuration
```

## Getting Started

### Prerequisites

- Node.js
- Yarn
- Hardhat

### Installation

1. Clone the repository:

   git clone https://github.com/Pixpel-io/Platform-EVM-Dex-Contracts

   ```
   switch folder
   cd pixpel-core and cd pixpel-periphery
   ```

2. Install dependencies:

   ```
   yarn install
   ```

3. Set up environment varaibles:
   ```
   Create a .env file based on the provided template and fill in the necessary values.
   ```

# Usage

For both Core Contracts and Periphery:

COMPILE CONTRACTS:

```
yarn compile
```

RUN TEST:

```
yarn test
```

DEPLOY CONTRACTS:

```
yarn deploy:file name
i-e yarn deploy:factroy
```

VERIFY CONTRACTS:

```
yarn hardhat run verify/verify.js --network <network-name>
```

## More Information

https://dex.pixpel.io/
