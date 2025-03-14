import chai, { expect } from 'chai'
import { Contract, ethers } from 'ethers'
import { AddressZero } from 'ethers/constants'
import { solidity, MockProvider, createFixtureLoader } from 'ethereum-waffle'
import { bigNumberify } from 'ethers/utils'
import { getCreate2Address } from './shared/utilities'
import { factoryFixture } from './shared/fixtures'

import PixpelSwapPair from '../build/PixpelSwapPair.json'

chai.use(solidity)

const TEST_ADDRESSES: [string, string] = [
  '0x1100000000000000000000000000000000000000',
  '0x2200000000000000000000000000000000000000'
]

describe('PixpelSwapFactory', () => {
  const provider = new MockProvider({
    hardfork: 'istanbul',
    mnemonic: 'horn horn horn horn horn horn horn horn horn horn horn horn',
    gasLimit: 9999999
  })
  const [wallet, other] = provider.getWallets()
  const loadFixture = createFixtureLoader(provider, [wallet, other])

  let factory: Contract
  beforeEach(async () => {
    const fixture = await loadFixture(factoryFixture)
    factory = fixture.factory
  })

  it('feeTo, feeToSetter, allPairsLength', async () => {
    expect(await factory.feeTo()).to.eq(AddressZero)
    expect(await factory.feeToSetter()).to.eq(wallet.address)
    expect(await factory.allPairsLength()).to.eq(0)
  })

  async function createPair(tokens: [string, string]) {
    // Ensure token order matches the contract logic
    const [token0, token1] = tokens[0].toLowerCase() < tokens[1].toLowerCase() ? tokens : [tokens[1], tokens[0]]
    // const salt = keccak256(solidityPack(['address', 'address'], [token0, token1]))
    const bytecode = `0x${PixpelSwapPair.evm.bytecode.object}`
    const create2Address = getCreate2Address(factory.address, [token0, token1], bytecode)
    await expect(factory.createPair(...tokens))
      .to.emit(factory, 'PairCreated')
      .withArgs(TEST_ADDRESSES[0], TEST_ADDRESSES[1], create2Address, bigNumberify(1))

    // factory.on('Debug', (...args) => {
    //   console.log('Debug Event Emitted:', args)
    // })
    // const tx = await factory.createPair(token0, token1)
    // const receipt = await tx.wait()
    // // Emit logs for debugging
    // for (const log of receipt.logs) {
    //   try {
    //     const parsedLog = factory.interface.parseLog(log)
    //     console.log('Event Emitted:', parsedLog.name, parsedLog.values)
    //   } catch (err) {
    //     console.log('Unknown Log:', log)
    //   }
    // }
    // console.log('Actual Deployed Pair Address:', receipt.logs[2].args.pair)
    // await expect(tx)
    //   .to.emit(factory, 'Debug')
    //   .withArgs('Pair created', token0, token1, create2Address)

    console.log('Pair created successfully:')

    await expect(factory.createPair(...tokens)).to.be.reverted // PixpelSwap: PAIR_EXISTS
    console.log('Verified pair creation reverts for duplicate pair.')

    await expect(factory.createPair(...tokens.slice().reverse())).to.be.reverted // PixpelSwap: PAIR_EXISTS

    expect(await factory.getPair(...tokens)).to.eq(create2Address)
    expect(await factory.getPair(...tokens.slice().reverse())).to.eq(create2Address)
    expect(await factory.allPairs(0)).to.eq(create2Address)
    expect(await factory.allPairsLength()).to.eq(1)

    const pair = new Contract(create2Address, JSON.stringify(PixpelSwapPair.abi), provider)
    expect(await pair.factory()).to.eq(factory.address)
    expect(await pair.token0()).to.eq(TEST_ADDRESSES[0])
    expect(await pair.token1()).to.eq(TEST_ADDRESSES[1])

    console.log('Token pair contract verified successfully.')
  }

  it('createPair', async () => {
    await createPair(TEST_ADDRESSES)
  })

  it('createPair:reverse', async () => {
    await createPair(TEST_ADDRESSES.slice().reverse() as [string, string])
  })

  it('createPair:gas', async () => {
    const tx = await factory.createPair(...TEST_ADDRESSES)
    const receipt = await tx.wait()
    expect(receipt.gasUsed.toNumber()).to.be.within(2480000, 2513000)
  })

  it('setFeeTo', async () => {
    await expect(factory.connect(other).setFeeTo(other.address)).to.be.revertedWith('PixpelSwap: FORBIDDEN')
    await factory.setFeeTo(wallet.address)
    expect(await factory.feeTo()).to.eq(wallet.address)
  })

  it('setFeeToSetter', async () => {
    await expect(factory.connect(other).setFeeToSetter(other.address)).to.be.revertedWith('PixpelSwap: FORBIDDEN')
    await factory.setFeeToSetter(other.address)
    expect(await factory.feeToSetter()).to.eq(other.address)
    await expect(factory.setFeeToSetter(wallet.address)).to.be.revertedWith('PixpelSwap: FORBIDDEN')
  })
})
