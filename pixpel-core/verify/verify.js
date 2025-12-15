const { run } = require('hardhat')
const {
  SkaleFactory,
  AmoyFactory,
  AvaxFactory,
  SkaleNebulaFactory,
  SeiMainnetFactory,
  SeiTestnetFactory,
  zeechainTestnetFactory
} = require('../deployedAddress')
async function verifyContract() {
  const contractAddress = zeechainTestnetFactory

  // const constructorArguments = ['0xfECBe146FcB9FcEF4c871442B2F53ff6D0f7Ff4c']
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
