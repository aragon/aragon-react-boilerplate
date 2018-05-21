import Aragon from '@aragon/client'

const app = new Aragon()

const initialState = {
  count: 0
}
app.store((state, event) => {
  if (state === null) state = initialState

  switch (event.event) {
    case 'Increment':
      return { count: parseInt(state.count, 10) + parseInt(event.returnValues.step, 10) }
    case 'Decrement':
      return { count: parseInt(state.count, 10) - parseInt(event.returnValues.step, 10) }
    default:
      return state
  }
})
