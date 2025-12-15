require('dotenv').config()
const { ethers } = require('ethers')
const { deployContract } = require('ethereum-waffle')

// Import compiled contract artifacts

const Erc20 = require('../build/ERC20.json')

async function main() {
  // Connect to Polygon network
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)

  // Create wallet instance
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  console.log('Deploying contracts with account:', wallet.address)
  const initial_supply = ethers.utils.parseUnits('1000000', 18)
  // Deploy PixpelSwap contract using ethereum-waffle's deployContract function
  const token = await deployContract(wallet, Erc20, [initial_supply], {
    gasLimit: 4700000,
    gasPrice: ethers.utils.parseUnits('30', 'gwei') // Example gas price, adjust as needed
  })
  console.log('Token deployed at:', token.address)
}

main().catch(error => {
  console.error('Deployment failed:', error)
  process.exit(1)
})
