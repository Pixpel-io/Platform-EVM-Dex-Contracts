# 🚀 Platform-EVM-Dex-Contracts

## 🌟 Overview

This repository is your one-stop destination for managing **Core Contracts** and **Periphery** components for an EVM-based DEX platform.

- **Core Contracts**: Essential smart contracts for core functionalities.
- **Periphery**: Supporting tools and utilities to interact with the Core.

Both components share a consistent folder structure for easy navigation and organization.

---

## 📂 Repository Folder Structure

### 📦 Core Contracts

The `Core Contracts` folder is structured as follows:

```plaintext
Core Contracts/
├── build/              # Compiled contracts
├── cache/              # Build artifacts cache
├── contracts/          # Smart contract files
├── deploy/             # Deployment scripts
├── node_modules/       # Node.js dependencies
├── test/               # Test cases
│   ├── shared/         # Shared deployment for tests
├── .env                # Environment variables
├── .gitattributes      # Git attributes
├── .gitignore          # Files to ignore in Git
├── .mocharc.json       # Mocha configuration
├── .prettierrc         # Prettier configuration
├── .waffle.json        # Waffle configuration
├── deployedAddress.js  # Deployed contract addresses
├── hardhat.config.js   # Hardhat configuration
├── LICENSE             # License file
├── package.json        # Node.js package configuration
├── README.md           # This README file
├── tsconfig.json       # TypeScript configuration
└── yarn.lock           # Yarn lock file
```

### 📦 V2-Periphery

The `V2-Periphery` folder mirrors the structure of Core Contracts for uniformity:

```plaintext
V2-Periphery/
├── build/              # Compiled contracts
├── cache/              # Build artifacts cache
├── contracts/          # Smart contract files
├── deploy/             # Deployment scripts
├── node_modules/       # Node.js dependencies
├── test/               # Test cases
│   ├── shared/         # Shared deployment for tests
├── .env                # Environment variables
├── .gitattributes      # Git attributes
├── .gitignore          # Files to ignore in Git
├── .mocharc.json       # Mocha configuration
├── .prettierrc         # Prettier configuration
├── .waffle.json        # Waffle configuration
├── deployedAddress.js  # Deployed contract addresses
├── hardhat.config.js   # Hardhat configuration
├── LICENSE             # License file
├── package.json        # Node.js package configuration
├── tsconfig.json       # TypeScript configuration
```

---

## 🚀 Getting Started

### ✅ Prerequisites

Ensure you have the following installed:

- [Node.js](https://nodejs.org/)
- [Yarn](https://yarnpkg.com/)
- [Hardhat](https://hardhat.org/)

### 📥 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Pixpel-io/Platform-EVM-Dex-Contracts
   ```

   Navigate to the respective folder:

   ```bash
   cd pixpel-core
   cd pixpel-periphery
   ```

2. Install dependencies:

   ```bash
   yarn install
   ```

3. Configure environment variables:

   Create a `.env` file based on the provided template and fill in the necessary values.

---

## 🛠️ Usage

### Core Contracts and Periphery

#### 📌 Compile Contracts:

```bash
yarn compile
```

#### 📌 Run Tests:

```bash
yarn test
```

#### 📌 Note:

```bash
To recompile or deploy to new network need to change byte code hash for uniswap pair lib
```

#### 📌 Deploy Contracts:

```bash
yarn deploy:<file-name>
# Example: yarn deploy:factory
```

#### 📌 Verify Contracts:

```bash
yarn hardhat run verify/verify.js --network <network-name>
```

---

## 🌐 More Information

Visit our official platform: [dex.pixpel.io](https://dex.pixpel.io/)

---
