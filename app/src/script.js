import 'core-js/stable'
import 'regenerator-runtime/runtime'
import Aragon, { events } from '@aragon/api'

const app = new Aragon()

app.store(async (state, { event }) => {
  let nextState = { ...state }

  // Initial state
  if (state == null) {
    nextState = {
      count: await getValue(),
    }
  }

  switch (event) {
    case 'Increment':
      nextState = { ...nextState, count: await getValue() }
      break
    case 'Decrement':
      nextState = { ...nextState, count: await getValue() }
      break
    case events.SYNC_STATUS_SYNCING:
      nextState = { ...nextState, isSyncing: true }
      break
    case events.SYNC_STATUS_SYNCED:
      nextState = { ...nextState, isSyncing: false }
      break
  }

  return nextState
})

async function getValue() {
  return parseInt(await app.call('value').toPromise(), 10)
}
