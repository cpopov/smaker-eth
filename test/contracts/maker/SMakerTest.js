const SToken = artifacts.require('./tokens/SToken.sol')
const SMaker = artifacts.require('./maker/SMaker.sol')
const chai = require('chai')
const expect = chai.expect
const BN = require('bn.js')
const bnChai = require('bn-chai')
chai.use(bnChai(BN))
const expectRevert = require('../helpers').expectRevert

contract('SMaker', function (accounts) {
  let longToken
  let shortToken
  let stableCoin
  let sMaker
  const creatorAccount = accounts[0]
  const user1Account = accounts[1]
  const user2Account = accounts[2]
  const oracleAccount = accounts[3]
  const DECIMALS = 18
  const PRICE_DECIMALS = 4
  const oneCoin = new BN(1).mul(new BN(10).pow(new BN(DECIMALS)))
  const twoCoins = new BN(2).mul(new BN(10).pow(new BN(DECIMALS)))
  const tenCoins = new BN(10).mul(new BN(10).pow(new BN(DECIMALS)))
  const hundredCoins = new BN(100).mul(new BN(10).pow(new BN(DECIMALS)))
  const thousandCoins = new BN(1000).mul(new BN(10).pow(new BN(DECIMALS)))

  let init = async () => {
    longToken = await SToken.new(0, 'SPY', 'S&P 500', false, {from: creatorAccount})
    shortToken = await SToken.new(0, 'XSPY', 'S&P 500 Short', true, {from: creatorAccount})
    stableCoin = await SToken.new(thousandCoins, 'USD', 'USD', false, {from: creatorAccount})
    // give each user 10 USD
    await stableCoin.transfer(user1Account, tenCoins, {from: creatorAccount})

    sMaker = await SMaker.new('SPY', stableCoin.address, shortToken.address, longToken.address, oracleAccount, {from: creatorAccount})
    await sMaker.setPrice(10 ** PRICE_DECIMALS, {from: oracleAccount})

    // transfer ownership to sMaker
    await longToken.transferOwnership(sMaker.address, {from: creatorAccount})
    await shortToken.transferOwnership(sMaker.address, {from: creatorAccount})
  }

  let logSMakerState = async (sMaker) => {
    let pos = await sMaker.getPosition({from: user1Account})
    console.log('pos:', pos[0].toString(), pos[1].toString(), pos[2].toString())
    const collateral = await sMaker.getCollateral({from: user1Account})
    console.log('collateral:', collateral.toString())
    const reqCollateral = await sMaker.getRequiredCollateral({from: user1Account})
    console.log('required collateral:', reqCollateral.toString())
    const pnl = await sMaker.getPnl({from: user1Account})
    console.log('pnl:', pnl.toString())
  }

  describe('Token minting', () => {
    beforeEach(init)

    it('a user should be able to mint new long tokens if he provides collateral', async () => {
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintLongTokens(oneCoin, {from: user1Account})

      // assert that stable coin has been taken as collateral
      let coinBalance = await stableCoin.balanceOf.call(user1Account)
      expect(coinBalance).to.eq.BN(tenCoins.sub(oneCoin.div(new BN(5))))

      // assert that user1 got the S&P token
      let sTokenBalance = await longToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(oneCoin)

      logSMakerState(sMaker)
    })

    it('a user should be able to mint new short tokens if he provides collateral', async () => {
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintShortTokens(oneCoin, {from: user1Account})
      // assert that stable coin has been taken as collateral
      let coinBalance = await stableCoin.balanceOf.call(user1Account)
      expect(coinBalance).to.eq.BN(tenCoins.sub(oneCoin.div(new BN(5))))

      // assert that user1 got the S&P token
      let sTokenBalance = await shortToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(oneCoin)

      logSMakerState(sMaker)
    })

    it('a user should be able to mint new long and short tokens if he provides collateral', async () => {
      // given existing long tokens
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintLongTokens(oneCoin, {from: user1Account})

      await logSMakerState(sMaker)

      // mint short tokens
      await sMaker.mintShortTokens(twoCoins, {from: user1Account})

      await logSMakerState(sMaker)

      // assert that stable coin has been taken as collateral
      let coinBalance = await stableCoin.balanceOf.call(user1Account)
      expect(coinBalance).to.eq.BN(tenCoins.sub(oneCoin.div(new BN(5))))

      // assert that user1 got the S&P token
      let sTokenBalance = await longToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(oneCoin)
      sTokenBalance = await shortToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(twoCoins)
    })

  })

  describe('Token burning', () => {
    beforeEach(async () => {
      await init()
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintLongTokens(twoCoins, {from: user1Account})
      await sMaker.mintShortTokens(oneCoin, {from: user1Account})
    })

    it('a user should be able to burn long tokens', async () => {
      await sMaker.burnLongTokens(oneCoin, {from: user1Account})

      // assert that SToken is burned
      let sTokenBalance = await longToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(oneCoin)

      // assert that collateral is freed

      await logSMakerState(sMaker)
    })

    it('a user should be able to burn short tokens', async () => {
      await sMaker.burnShortTokens(oneCoin, {from: user1Account})

      // assert that SToken is burned
      let sTokenBalance = await shortToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(0)

      // assert that collateral is freed

      await logSMakerState(sMaker)
    })

    it('a user should be able to burn long and short tokens', async () => {
      await sMaker.burnLongTokens(oneCoin, {from: user1Account})
      await sMaker.burnShortTokens(oneCoin, {from: user1Account})

      // assert that SToken is burned
      let sTokenBalance = await longToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(oneCoin)

      sTokenBalance = await shortToken.balanceOf.call(user1Account)
      expect(sTokenBalance).to.eq.BN(0)

      // assert that collateral is freed

      await logSMakerState(sMaker)
    })
  })

  describe('Price change', () => {
    beforeEach(async () => {
      await init()
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintLongTokens(oneCoin, {from: user1Account})
    })

    it('price increase should update pnl and required collateral', async () => {
      await logSMakerState(sMaker)

      await sMaker.setPrice(2 * 10 ** PRICE_DECIMALS, {from: oracleAccount})

      let reqCollateral = await sMaker.getRequiredCollateral({from: user1Account})
      console.log('required collateral after:', reqCollateral.toString())
      let pnl = await sMaker.getPnl({from: user1Account})
      console.log('pnl after:', pnl.toString ())

      expect(reqCollateral).to.eq.BN(0)
      expect(pnl).to.eq.BN(oneCoin)
    })

    it('price decrease should update pnl and required collateral', async () => {
      await logSMakerState(sMaker)

      await sMaker.setPrice(10 ** PRICE_DECIMALS / 2, {from: oracleAccount})

      let reqCollateral = await sMaker.getRequiredCollateral({from: user1Account})
      console.log('required collateral after:', reqCollateral.toString())
      let pnl = await sMaker.getPnl({from: user1Account})
      console.log('pnl after:', pnl.toString())

      expect(pnl).to.eq.BN(oneCoin.div(new BN(2)).neg())
      expect(reqCollateral).to.eq.BN(new BN(7).mul(new BN(10).pow(new BN(DECIMALS-1))))
    })

    it('price increase should update pnl and and required collateral with long and short positions', async () => {
      await sMaker.mintShortTokens(oneCoin.div(new BN(2)), {from: user1Account})
      await logSMakerState(sMaker)

      await sMaker.setPrice(2 * 10 ** PRICE_DECIMALS, {from: oracleAccount})

      let reqCollateral = await sMaker.getRequiredCollateral({from: user1Account})
      console.log('required collateral after:', reqCollateral.toString())
      let pnl = await sMaker.getPnl({from: user1Account})
      console.log('pnl after:', pnl.toString())

      expect(pnl).to.eq.BN(oneCoin.div(new BN(2)))
      expect(reqCollateral).to.eq.BN(0)
    })

    it('price increase and decrease should update pnl and and required collateral with long and short positions', async () => {
      await logSMakerState(sMaker)

      await sMaker.setPrice(3 * 10 ** PRICE_DECIMALS, {from: oracleAccount})

      await sMaker.mintShortTokens(oneCoin, {from: user1Account})

      await sMaker.setPrice(2 * 10 ** PRICE_DECIMALS, {from: oracleAccount})

      let reqCollateral = await sMaker.getRequiredCollateral({from: user1Account})
      console.log('required collateral after:', reqCollateral.toString())
      let pnl = await sMaker.getPnl({from: user1Account})
      console.log('pnl after:', pnl.toString())

      expect(pnl).to.eq.BN(twoCoins)
      expect(reqCollateral).to.eq.BN(0)
    })
  })

  // test collateral redemption
  describe('Collateral redemption', () => {
    beforeEach(init)

    it('a user should be able redeem collateral', async () => {
      await stableCoin.approve(sMaker.address, tenCoins, {from: user1Account})
      await sMaker.mintLongTokens(oneCoin, {from: user1Account})
      await logSMakerState(sMaker)
      await sMaker.burnLongTokens(oneCoin, {from: user1Account})
      await logSMakerState(sMaker)
      let collateral = await sMaker.getCollateral({from: user1Account})
      await sMaker.redeemCollateral(collateral, {from: user1Account})
      await logSMakerState(sMaker)
      collateral = await sMaker.getCollateral({from: user1Account})
      expect(collateral).to.eq.BN(0)
      const usd = await stableCoin.balanceOf(user1Account, {from: user1Account})
      expect(usd).to.eq.BN(tenCoins)
    })
  })

  // TODO liquidation
})
