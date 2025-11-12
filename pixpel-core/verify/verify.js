const { run } = require('hardhat')
const { SkaleFactory, AmoyFactory, AvaxFactory, SkaleNebulaFactory, SeiMainnetFactory } = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = SeiMainnetFactory
  const constructorArguments = ['0xfECBe146FcB9FcEF4c871442B2F53ff6D0f7Ff4c']

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
