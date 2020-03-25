const TokenContract = artifacts.require('tokens/SToken.sol')
const chai = require('chai')
const expect = chai.expect
const BN = require('bn.js')
const bnChai = require('bn-chai')
chai.use(bnChai(BN))
const expectRevert = require('../helpers').expectRevert

contract('SToken', function (accounts) {
  let tokenContract
  const creatorAccount = accounts[0]
  const userAccount = accounts[1]
  const decimals = 18
  const initialAmount = new BN(100).mul(new BN(10).pow(new BN(6 + decimals)))

  let init = async () => {
    tokenContract = await TokenContract.new(initialAmount, 'SPY', 'S&P 500', false, {from: creatorAccount})
  }

  describe('Creation', () => {
    beforeEach(init)

    it('should give all the initial balance to the creator', async () => {
      let balance = await tokenContract.balanceOf.call(creatorAccount)
      expect(balance).to.eq.BN(initialAmount)
      let decimalsResult = await tokenContract.decimals.call()
      expect(decimalsResult).to.eq.BN(decimals)
      let symbol = await tokenContract.symbol.call()
      expect(symbol).to.equal('SPY')
    })
  })

  describe('Normal Transfers', () => {
    beforeEach(init)

    it('ether transfer should be reversed.', async () => {
      await expectRevert(tokenContract.sendTransaction({from: userAccount, value: web3.utils.toWei('10', 'Ether')}))
      let balanceAfter = await tokenContract.balanceOf.call(creatorAccount)
      expect(balanceAfter).to.eq.BN(initialAmount)
    })

    it('should transfer all tokens', async () => {
      let success = await tokenContract.transfer(userAccount, initialAmount, {from: creatorAccount})
      assert.ok(success)
      let balance = await tokenContract.balanceOf.call(userAccount)
      expect(balance).to.eq.BN(initialAmount)
    })

    it('should fail when trying to transfer initialAmount + 1', async () => {
      await expectRevert(tokenContract.transfer(userAccount, initialAmount.add(new BN(1)), {from: creatorAccount}))
    })

    it('transfers: should transfer 1 token', async () => {
      let res = await tokenContract.transfer(userAccount, 1, {from: creatorAccount})
      assert.ok(res)

      // check event log
      const transferLog = res.logs[0]
      expect(transferLog.args.from).to.equal(creatorAccount)
      expect(transferLog.args.to).to.equal(userAccount)
      expect(transferLog.args.value.toString()).to.equal('1')
    })
  })

  describe('Approvals', () => {
    beforeEach(init)

    it('when msg.sender approves 100 to accounts[1] then account[1] should be able to withdraw 20 from msg.sender', async () => {
      let sender = creatorAccount

      let res = await tokenContract.approve(userAccount, 100, {from: sender})
      assert.ok(res)

      // check event logs
      const approvalLog = res.logs[0]
      expect(approvalLog.args.owner).to.equal(creatorAccount)
      expect(approvalLog.args.spender).to.equal(userAccount)
      expect(approvalLog.args.value.toString()).to.equal('100')

      let allowance = await tokenContract.allowance.call(sender, userAccount)
      expect(allowance).to.eq.BN(100)
      let success = await tokenContract.transferFrom(sender, accounts[2], 20, {from: userAccount})
      assert.ok(success)
      allowance = await tokenContract.allowance.call(sender, userAccount)
      expect(allowance).to.eq.BN(80)
      let balance = await tokenContract.balanceOf.call(accounts[2])
      expect(balance).to.eq.BN(20)
      balance = await tokenContract.balanceOf.call(creatorAccount)
      expect(balance.add(new BN(20))).to.eq.BN(initialAmount)
    })

    it('when msg.sender approves 100 to accounts[1] then account[1] should not be able to withdraw 101 from msg.sender', async () => {
      let sender = creatorAccount

      let success = await tokenContract.approve(userAccount, 100, {from: sender})
      assert.ok(success)

      let allowance = await tokenContract.allowance.call(sender, userAccount)
      expect(allowance).to.eq.BN(100)

      await expectRevert(tokenContract.transferFrom(sender, accounts[2], 101, {from: userAccount}))
    })

    it('withdrawal from account with no allowance should fail', async () => {
      await expectRevert(tokenContract.transferFrom(creatorAccount, accounts[2], 60, {from: accounts[1]}))
    })
  })

  describe('Token Burning', () => {
    beforeEach(init)

    it.skip('only owner should be able to burn tokens', async () => {
      tokenContract.transfer(1, {from: creatorAccount});
      await expectRevert(tokenContract.burn(userAccount, 1, {from: userAccount}))
    })

    it('owner should be able to burn X tokens', async () => {
      const amountToBurn = new BN(11).mul(new BN(10).pow(new BN(6 + decimals)))
      await tokenContract.burn(creatorAccount, amountToBurn, {from: creatorAccount})
      let tokenBalance = await tokenContract.balanceOf.call(creatorAccount)
      expect(tokenBalance).to.eq.BN(initialAmount.sub(amountToBurn))
    })
  })

  describe('Token Minting', () => {
    beforeEach(init)

    it('only token owner should be able to mint tokens', async () => {
      await expectRevert(tokenContract.mint(userAccount, 1, {from: userAccount}))
    })

    it('owner should be able to mint X tokens', async () => {
      const amountToMint = new BN(11).mul(new BN(10).pow(new BN(6 + decimals)))
      await tokenContract.mint(creatorAccount, amountToMint)
      let tokenBalance = await tokenContract.balanceOf.call(creatorAccount)
      expect(tokenBalance).to.eq.BN(initialAmount.add(amountToMint))
    })
  })
})
