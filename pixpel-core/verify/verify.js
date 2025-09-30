const { run } = require('hardhat')
const { SkaleFactory, AmoyFactory } = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = AmoyFactory
  const constructorArguments = []

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
