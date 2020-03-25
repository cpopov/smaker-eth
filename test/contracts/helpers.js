const expect = require('chai').expect
const BN = require('bn.js')

async function expectRevert (promise, reason) {
  try {
    await promise
  } catch (error) {
    expect(error.message).to.include('revert', `Expected "revert", got ${error} instead`)
    if (reason) {
      expect(error.reason).to.equal(reason, `Expected revert reason ${reason}, got ${error.reason} instead`)
    }
    return
  }
  throw new Error('Expected revert not received')
}

async function expectError (promise) {
  try {
    await promise
  } catch (error) {
    return
  }
  throw new Error('Expected error not received')
}

/**
 * Converts to real token number, considering decimals
 * @param tokenBalance
 * @param decimals number of decimals. Default is 18
 */
function toRealTokenNumber(tokenBalance, decimals = 18) {
  return tokenBalance.divRound(new BN(10).pow(new BN(decimals))).toNumber()
}

module.exports = {
  expectRevert,
  expectError,
  toRealTokenNumber
}
