const { run } = require('hardhat')
const { Factory } = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = Factory
  const constructorArguments = ['0x609DE8dd52FA1Cf32Ff6C4eF7EF18c5d5a87aA62']

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
