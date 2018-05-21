import Aragon from '@aragon/client'

const app = new Aragon()

const initialState = {
  count: 0
}
app.store((state, event) => {
  if (state === null) state = initialState

  switch (event.event) {
    case 'Increment':
      return { count: parseInt(state.count) + parseInt(event.returnValues.step) }
    case 'Decrement':
      return { count: parseInt(state.count) - parseInt(event.returnValues.step) }
    default:
      return state
  }
})
