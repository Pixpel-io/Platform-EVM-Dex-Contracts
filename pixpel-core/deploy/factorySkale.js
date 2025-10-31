require('dotenv').config()
const { ethers } = require('ethers')
const { deployContract } = require('ethereum-waffle')

// Import compiled contract artifacts

const PixpelSwapFactory = require('../build/PixpelSwapFactorySkale.json')

async function main() {
  // Connect to Polygon network
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)

  // Create wallet instance
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  console.log('Deploying contracts with account:', wallet.address)

  // Deploy PixpelSwap contract using ethereum-waffle's deployContract function
  const factory = await deployContract(wallet, PixpelSwapFactory, [], {
    gasLimit: 4700000,
    gasPrice: ethers.utils.parseUnits('30', 'gwei') // Example gas price, adjust as needed
  })
  console.log('PixpelSwapFactory deployed at:', factory.address)
  const feeTo = await factory.feeTo()
  const superAdmin = await factory.superAdmin()
  const isAdmin = await factory.isAdmin(wallet.address)
  console.log(`PixpelSwap feeTo: ${feeTo}`)

  console.log('PixpelSwap superAdmin:', superAdmin)
  console.log('Is deployer admin?:', isAdmin)
}

main().catch(error => {
  console.error('Deployment failed:', error)
  process.exit(1)
})
