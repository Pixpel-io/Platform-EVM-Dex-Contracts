const { avax, seiMainnet } = require('./deployedAddress')

require('@nomiclabs/hardhat-ethers')
require('@nomicfoundation/hardhat-verify')
require('dotenv').config()
require('@nomicfoundation/hardhat-toolbox')
// require('hardhat-contract-sizer')
module.exports = {
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: {
        enabled: true,

        runs: 999999 // Match Waffle's optimizer runs
      },
      outputSelection: {
        '*': ['evm.bytecode.object', 'evm.deployedBytecode.object', 'abi'],
        '*': {
          '': ['ast']
        }
      },
      evmVersion: 'istanbul' // Match Waffle's EVM version
    }
  },

  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true //  should be valid
  },
  networks: {
    amoy: {
      url: 'https://polygon-amoy.infura.io/v3/090cef2ffe354730bd646be862608f61', // Polygon RPC URL
      chainId: 80002,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    'nebula-testnet': {
      url: 'https://lanky-ill-funny-testnet-indexer.skalenodes.com:10136',
      chainId: 37084624,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    'nebula-mainnet': {
      url: 'https://mainnet.skalenodes.com/v1/green-giddy-denebola',
      chainId: 1482601649,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    l1x: {
      url: 'https://rpc.l1x.foundation',
      chainId: 1066,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    avax: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      chainId: 43114,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    polygon: {
      url: 'https://polygon-mainnet.infura.io/v3/090cef2ffe354730bd646be862608f61',
      chainId: 137,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    },
    // Sei testnet configuration
    seitestnet: {
      url: 'https://evm-rpc-testnet.sei-apis.com',
      chainId: 1328, // Sei testnet chain ID
      accounts: [`0x${process.env.PRIVATE_KEY}`]
      // gasPrice: 2000000000 // 2 gwei = 2 nsei
    },
    // Sei mainnet configuration
    seimainnet: {
      url: 'https://evm-rpc.sei-apis.com',
      chainId: 1329, // Sei mainnet chain ID
      accounts: [`0x${process.env.PRIVATE_KEY}`]
      // gasPrice: 2000000000 // 2 gwei = 2 nsei
    },
    zeechainTestnet: {
      url: process.env.RPC_URL,
      chainId: 8408,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  },
  etherscan: {
    // apiKey: process.env.POLYGONSCAN_API_KEY,
    apiKey: {
      'nebula-testnet': 'na',
      'nebula-mainnet': 'na',
      amoy: process.env.POLYGONSCAN_API_KEY,
      avax: process.env.POLYGONSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      apiKey: process.env.POLYGONSCAN_API_KEY,
      l1x: 'na',
      seimainnet: 'na',
      seitestnet: 'na',
      zeechainTestnet: 'na'
    },
    customChains: [
      {
        network: 'amoy',
        chainId: 80002,

        urls: {
          apiURL: 'https://api.etherscan.io/v2/api?chainid=80002',
          browserURL: 'https://amoy.polygonscan.com'
        }
      },
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
      },
      {
        network: 'l1x',
        chainId: 1066,
        urls: {
          apiURL: 'https://l1xapp.com/explorer/api',
          browserURL: 'https://l1xapp.com/explorer'
        }
      },
      {
        network: 'avax',
        chainId: 43114,
        urls: {
          apiURL: 'https://api.snowtrace.io/api',
          browserURL: 'https://snowtrace.io/'
        }
      },
      {
        network: 'polygon',
        chainId: 137,
        urls: {
          apiURL: 'https://api.etherscan.io/v2/api?chainid=137',
          browserURL: 'https://polygonscan.com/'
        }
      },
      {
        network: 'seimainnet',
        chainId: 1329,
        urls: {
          apiURL: 'https://seitrace.com/pacific-1/api',
          browserURL: 'https://seitrace.com'
        }
      },
      {
        network: 'seitestnet',
        chainId: 1328,
        urls: {
          apiURL: 'https://seitrace.com/atlantic-2/api',
          browserURL: 'https://testnet.seitrace.com'
        }
      },
      {
        network: 'zeechainTestnet',
        chainId: 8408,
        urls: {
          apiURL: 'https://zentrace.io/api',
          browserURL: 'https://zentrace.io'
        }
      }
    ]
  }
}
