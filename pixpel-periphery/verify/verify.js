const { run } = require('hardhat')
const { ethers } = require('ethers')
const {
  Factory,
  Router2,
  amoyRouter,
  AmoyFactory,
  Weth,
  Token,
  Token1,
  SkaleRouter,
  SkaleToken4,
  skaleUSDC
} = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = amoyRouter // Replace with actual contract address
  const constructorArguments = [AmoyFactory, Weth]

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
