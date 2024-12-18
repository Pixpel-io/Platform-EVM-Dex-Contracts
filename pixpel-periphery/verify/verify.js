const { run } = require('hardhat')
const { ethers } = require('ethers')
const { Factory, Router2, Weth, Token } = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = Router2 // Replace with actual contract address
  const constructorArguments = [Factory, Weth]

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
