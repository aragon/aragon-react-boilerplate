const { assertRevert } = require('@aragon/test-helpers/assertThrow')
const { deployDAO, getEventFromReceipt } = require('./helper')

const CounterApp = artifacts.require('CounterApp.sol')

const ANY_ADDRESS = '0xffffffffffffffffffffffffffffffffffffffff'

contract('CounterApp', ([_, appManager, user]) => {
  let dao, acl, app

  beforeEach('deploy dao', async () => {
    ({dao, acl} = await deployDAO(appManager))
  })

  beforeEach('deploy and initialize app', async () => {

    // Deploy the app's logic implementation or "base" contract.
    const appBase = await CounterApp.new()

    // Instantiate a proxy for the app.
    const instanceReceipt = await dao.newAppInstance('0x1234', appBase.address, '0x', false, { from: appManager })
    app = CounterApp.at(getEventFromReceipt(instanceReceipt, 'NewAppProxy').args.proxy)

    // Grant app permissions.
    const INCREMENT_ROLE = await app.INCREMENT_ROLE()
    const DECREMENT_ROLE = await app.DECREMENT_ROLE()
    await acl.createPermission(ANY_ADDRESS, app.address, INCREMENT_ROLE, appManager, { from: appManager, })
    await acl.createPermission(ANY_ADDRESS, app.address, DECREMENT_ROLE, appManager, { from: appManager, })

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
