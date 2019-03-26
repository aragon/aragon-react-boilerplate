/* global artifacts contract before beforeEach it assert */
const { assertRevert } = require('@aragon/test-helpers/assertThrow')

const CounterApp = artifacts.require('CounterApp.sol')
const DAOFactory = artifacts.require(
  '@aragon/core/contracts/factory/DAOFactory'
)
const EVMScriptRegistryFactory = artifacts.require(
  '@aragon/core/contracts/factory/EVMScriptRegistryFactory'
)
const ACL = artifacts.require('@aragon/core/contracts/acl/ACL')
const Kernel = artifacts.require('@aragon/core/contracts/kernel/Kernel')

const getContract = name => artifacts.require(name)

const ANY_ADDR = '0xffffffffffffffffffffffffffffffffffffffff'

contract('CounterApp', accounts => {
  let APP_MANAGER_ROLE, INCREMENT_ROLE, DECREMENT_ROLE
  let daoFact, appBase, app

  const root = accounts[0]
  const holder = accounts[1]

  before(async () => {
    const kernelBase = await getContract('Kernel').new(true) // petrify immediately
    const aclBase = await getContract('ACL').new()
    const regFact = await EVMScriptRegistryFactory.new()
    daoFact = await DAOFactory.new(
      kernelBase.address,
      aclBase.address,
      regFact.address
    )
    appBase = await CounterApp.new()

    // Setup constants
    APP_MANAGER_ROLE = await kernelBase.APP_MANAGER_ROLE()
    INCREMENT_ROLE = await appBase.INCREMENT_ROLE()
    DECREMENT_ROLE = await appBase.DECREMENT_ROLE()
  })

  beforeEach(async () => {
    const r = await daoFact.newDAO(root)
    const dao = Kernel.at(
      r.logs.filter(l => l.event === 'DeployDAO')[0].args.dao
    )
    const acl = ACL.at(await dao.acl())

    await acl.createPermission(root, dao.address, APP_MANAGER_ROLE, root, {
      from: root,
    })

    const receipt = await dao.newAppInstance(
      '0x1234',
      appBase.address,
      '0x',
      false,
      { from: root }
    )
    app = CounterApp.at(
      receipt.logs.filter(l => l.event === 'NewAppProxy')[0].args.proxy
    )

    await acl.createPermission(ANY_ADDR, app.address, INCREMENT_ROLE, root, {
      from: root,
    })
    await acl.createPermission(ANY_ADDR, app.address, DECREMENT_ROLE, root, {
      from: root,
    })
  })

  it('should be incremented', async () => {
    app.initialize()
    await app.increment(1)
    assert.equal(await app.value(), 1)
  })

  it('should not be decremented if already 0', async () => {
    app.initialize()
    return assertRevert(async () => {
      return app.decrement(1)
    })
  })
})
