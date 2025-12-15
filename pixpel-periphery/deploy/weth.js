require('dotenv').config()
const { ethers } = require('ethers')
const { deployContract } = require('ethereum-waffle')

// Import compiled contract artifacts

const Weth = require('../build/WETH9.json')

async function main() {
  // Connect to Polygon network
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)

  // Create wallet instance
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  console.log('Deploying contracts with account:', wallet.address)

  // Deploy PixpelSwap contract using ethereum-waffle's deployContract function
  const weth = await deployContract(wallet, Weth, [], {
    gasLimit: 4700000,
    gasPrice: ethers.utils.parseUnits('30', 'gwei') // Example gas price, adjust as needed
  })
  console.log('Weth deployed at:', weth.address)
}

main().catch(error => {
  console.error('Deployment failed:', error)
  process.exit(1)
})
