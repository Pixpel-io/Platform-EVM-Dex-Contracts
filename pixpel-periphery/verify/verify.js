const { run } = require('hardhat')
const { ethers } = require('ethers')
const addresses = require('../deployedAddress')

async function verifyContract() {
  const contractAddress = addresses.seiMainnet.Router
  const constructorArguments = [
    addresses.seiMainnet.Factory,
    addresses.seiMainnet.Weth,
    addresses.seiMainnet.LaunchPadAddress,
    addresses.seiMainnet.LPFundManager
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
