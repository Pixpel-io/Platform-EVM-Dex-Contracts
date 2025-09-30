//Note:to successfully run this file test uncomment the lines in PixpelSwapFactory contract
//commented with "only for test"

import { expect } from 'chai'
import { Contract, Wallet } from 'ethers'
import { MockProvider, deployContract } from 'ethereum-waffle'
import PixpelSwapFactoryArtifact from '../build/PixpelSwapFactory.json'

describe('PixpelSwapFactory - SKALE WETH Restriction', () => {
  const SKALE_CHAIN_ID = 37084624
  const SKALE_WETH = '0x95ac999302Ff402b39A8B952a662863338585d3c'
  const dummyToken = '0x000000000000000000000000000000000000dEaD'

  let factory: Contract
  let wallet: Wallet

  beforeEach(async () => {
    const provider = new MockProvider({
      ganacheOptions: {
        hardfork: 'istanbul',
        mnemonic: 'test test test test test test test test test test test junk',
        chainId: SKALE_CHAIN_ID
      }
    } as any)

    const [deployer] = provider.getWallets()
    wallet = deployer

    factory = await deployContract(deployer, PixpelSwapFactoryArtifact, [])
  })

  it('reverts when tokenA is SKALE_WETH', async () => {
    await factory.setChainIdOverride(37084624)
    await expect(factory.createPair(SKALE_WETH, dummyToken)).to.be.revertedWith(
      'PixpelSwapFactory: Native token pairs restricted on SKALE chain'
    )
  })

  it('reverts when tokenB is SKALE_WETH', async () => {
    await factory.setChainIdOverride(37084624)
    await expect(factory.createPair(dummyToken, SKALE_WETH)).to.be.revertedWith(
      'PixpelSwapFactory: Native token pairs restricted on SKALE chain'
    )
  })
})
