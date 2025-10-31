const { run } = require('hardhat')
const { ethers } = require('ethers')
const addresses = require('../deployedAddress')

async function verifyContract() {
  const contractAddress = addresses.avax.Router
  const constructorArguments = [
    addresses.avax.Factory,
    addresses.avax.Weth,
    addresses.avax.LaunchPadAddress,
    addresses.avax.LPFundManager
  ]

  console.log('Verifying contract...')
  try {
    await run('verify:verify', {
      address: contractAddress,
      constructorArguments: constructorArguments
    })
    console.log('Contract verified!')
  } catch (error) {
    console.error('Verification failed:', error)
  }
}

verifyContract()
