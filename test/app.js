/* global artifacts contract beforeEach it assert */

const { assertRevert } = require('@aragon/test-helpers/assertThrow')
const { hash } = require('eth-ens-namehash')
const deployDAO = require('./helpers/deployDAO')

const CounterApp = artifacts.require('CounterApp.sol')

const ANY_ADDRESS = '0xffffffffffffffffffffffffffffffffffffffff'

const getLog = (receipt, logName, argName) => {
  const log = receipt.logs.find(({ event }) => event === logName)
  return log ? log.args[argName] : null
}

const deployedContract = receipt => getLog(receipt, 'NewAppProxy', 'proxy')

contract('CounterApp', ([appManager, user]) => {
  let INCREMENT_ROLE, DECREMENT_ROLE
  let appBase, app

  // eslint-disable-next-line no-undef
  before('deploy base app', async () => {
    // Deploy the app's base contract.
    appBase = await CounterApp.new()

    INCREMENT_ROLE = await appBase.INCREMENT_ROLE()
    DECREMENT_ROLE = await appBase.DECREMENT_ROLE()
  })

  beforeEach('deploy dao and app', async () => {
    const { dao, acl } = await deployDAO(appManager)

    // Instantiate a proxy for the app, using the base contract as its logic implementation.
    const newAppInstanceReceipt = await dao.newAppInstance(
      hash('placeholder-app-name.aragonpm.test'), // appId - Unique identifier for each app installed in the DAO; can be any bytes32 string in the tests.
      appBase.address, // appBase - Location of the app's base implementation.
      '0x', // initializePayload - Used to instantiate and initialize the proxy in the same call (if given a non-empty bytes string).
      false, // setDefault - Whether the app proxy is the default proxy.
      { from: appManager }
    )
    app = await CounterApp.at(deployedContract(newAppInstanceReceipt))

    // Set up the app's permissions.
    await acl.createPermission(
      ANY_ADDRESS, // entity (who?) - The entity or address that will have the permission.
      app.address, // app (where?) - The app that holds the role involved in this permission.
      INCREMENT_ROLE, // role (what?) - The particular role that the entity is being assigned to in this permission.
      appManager, // manager - Can grant/revoke further permissions for this role.
      { from: appManager }
    )
    await acl.createPermission(
      ANY_ADDRESS,
      app.address,
      DECREMENT_ROLE,
      appManager,
      { from: appManager }
    )

    await app.initialize()
  })

  it('should be incremented by any address', async () => {
    await app.increment(1, { from: user })
    assert.equal(await app.value(), 1)
  })

  it('should not be decremented if already 0', async () => {
    await assertRevert(app.decrement(1), 'MATH_SUB_UNDERFLOW')
  })
})
