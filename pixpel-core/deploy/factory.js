require('dotenv').config()
const { ethers } = require('ethers')
const { deployContract } = require('ethereum-waffle')

// Import compiled contract artifacts

const PixpelSwapFactory = require('../build/PixpelSwapFactory.json')

async function main() {
  // Connect to Polygon network
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)

  // Create wallet instance
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  console.log('Deploying contracts with account:', wallet.address)

  // Deploy PixpelSwap contract using ethereum-waffle's deployContract function
  const factory = await deployContract(wallet, PixpelSwapFactory, [wallet.address], {
    gasLimit: 4700000,
    gasPrice: ethers.utils.parseUnits('30', 'gwei') // Example gas price, adjust as needed
  })

  console.log('PixpelSwapFactory deployed at:', factory.address)

  const feeToSetter = await factory.feeToSetter()
  const feeTo = await factory.feeTo()
  console.log(`PixpelSwap feeTo: ${feeTo}`)
  console.log('PixpelSwap feeToSetter:', feeToSetter)
}

main().catch(error => {
  console.error('Deployment failed:', error)
  process.exit(1)
})
