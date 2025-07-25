require('dotenv').config()
const { ethers } = require('ethers')
const { deployContract } = require('ethereum-waffle')

// Import compiled contract artifacts

const PixpelSwapRouter02 = require('../build/PixpelSwapRouter02.json')
const { Factory, Weth, AmoyFactory } = require('../deployedAddress')
async function main() {
  // Connect to Polygon network
  const provider = new ethers.providers.JsonRpcProvider(process.env.POLYGON_RPC_URL)
  // Create wallet instance
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  console.log('Deploying contracts with account:', wallet.address)

  // Deploy PixpelSwap contract using ethereum-waffle's deployContract function
  const router2 = await deployContract(wallet, PixpelSwapRouter02, [AmoyFactory, Weth], {
    gasLimit: 9000000,
    gasPrice: ethers.utils.parseUnits('30', 'gwei') // Example gas price, adjust as needed
  })

  console.log('PixpelSwapRouter2 deployed at:', router2.address)
}

main().catch(error => {
  console.error('Deployment failed:', error)
  process.exit(1)
})
