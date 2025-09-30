require('dotenv').config()
const { ethers } = require('ethers')

// Import compiled PixpelSwapPair artifact
const PixpelSwapPair = require('../artifacts/contracts/PixpelSwapPair.sol/PixpelSwapPair.json')

async function main() {
  // The creation code is the .bytecode field from your artifact
  const creationCode = PixpelSwapPair.bytecode

  // Compute keccak256 hash of creation code
  const initCodeHash = ethers.utils.keccak256(creationCode)

  console.log('PixpelSwapPair init code hash:', initCodeHash)
}

main().catch(error => {
  console.error('Error computing init code hash:', error)
  process.exit(1)
})
