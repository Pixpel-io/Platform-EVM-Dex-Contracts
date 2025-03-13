const { run } = require('hardhat')
const { ethers } = require('ethers')
const { Factory, Router2, Weth, Token, Token1, SkaleRouter, SkaleToken4, skaleUSDC } = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = skaleUSDC // Replace with actual contract address
  const constructorArguments = [ethers.utils.parseUnits('1000000', 18)]

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
