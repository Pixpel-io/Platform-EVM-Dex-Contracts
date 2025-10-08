const { run } = require('hardhat')
const { ethers } = require('ethers')
const addresses = require('../deployedAddress')

async function verifyContract() {
  const contractAddress = addresses.skale.Router
  const constructorArguments = [
    addresses.skale.Factory,
    addresses.skale.Weth,
    addresses.skale.LaunchPadAddress,
    addresses.skale.LPFundManager
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
