require('@nomiclabs/hardhat-ethers')
require('@nomicfoundation/hardhat-verify')
require('dotenv').config()

module.exports = {
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999 // Match Waffle's optimizer runs
      },
      outputSelection: {
        '*': {
          '*': ['evm.bytecode.object', 'evm.deployedBytecode.object', 'abi'],
          '': ['ast']
        }
      },
      evmVersion: 'istanbul' // Match Waffle's EVM version
    }
  },
  networks: {
    amoy: {
      url: 'https://polygon-amoy.infura.io/v3/090cef2ffe354730bd646be862608f61', // Polygon RPC URL
      chainId: 80002,
      accounts: [`0x${process.env.PRIVATE_KEY}`] // Your private key for deployment
    },
    'nebula-testnet': {
      url: 'https://lanky-ill-funny-testnet-indexer.skalenodes.com:10136',
      chainId: 37084624,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: {
      'nebula-testnet': 'na',
      'nebula-mainnet': 'na',
      amoy: process.env.POLYGONSCAN_API_KEY // Replace with your API key from PolygonScan
    },
    customChains: [
      {
        network: 'nebula-testnet',
        chainId: 37084624,
        urls: {
          apiURL: 'https://lanky-ill-funny-testnet.explorer.testnet.skalenodes.com/api',
          browserURL: 'https://lanky-ill-funny-testnet.explorer.testnet.skalenodes.com'
        }
      },

      {
        network: 'nebula-mainnet',
        chainId: 1482601649,
        urls: {
          apiURL: 'https://green-giddy-denebola.explorer.mainnet.skalenodes.com/api',
          browserURL: 'https://green-giddy-denebola.explorer.mainnet.skalenodes.com'
        }
      }
    ]
  }
}
