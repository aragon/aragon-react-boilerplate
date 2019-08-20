const { assertRevert } = require('@aragon/test-helpers/assertThrow')
const { getEventArgument } = require('@aragon/test-helpers/events')
const deployDAO = require('./helpers/deployDAO')

const CounterApp = artifacts.require('CounterApp.sol')

const ANY_ADDRESS = '0xffffffffffffffffffffffffffffffffffffffff'

contract('CounterApp', ([_, appManager, user]) => {
  let app

  beforeEach('deploy dao and app', async () => {
    const { dao, acl } = await deployDAO(appManager)

    // Deploy the app's base contract.
    const appBase = await CounterApp.new()

    // Instantiate a proxy for the app, using the base contract as its logic implementation.
    const instanceReceipt = await dao.newAppInstance('0x1234', appBase.address, '0x', false, { from: appManager })
    app = CounterApp.at(getEventArgument(instanceReceipt, 'NewAppProxy', 'proxy'))

    // Set up the app's permissions.
    await acl.createPermission(ANY_ADDRESS, app.address, await app.INCREMENT_ROLE(), appManager, { from: appManager, })
    await acl.createPermission(ANY_ADDRESS, app.address, await app.DECREMENT_ROLE(), appManager, { from: appManager, })

    await app.initialize()
  })

  it('should be incremented by any address', async () => {
    await app.increment(1, { from: user })
    assert.equal(await app.value(), 1)
  })

  it('should not be decremented if already 0', async () => {
    await assertRevert(
      app.decrement(1),
      'MATH_SUB_UNDERFLOW'
    )
  })
})
