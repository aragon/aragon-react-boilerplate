import React from 'react'
import {
  AragonApp,
  Button,
  Text,

  observe
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'
import styled from 'styled-components'

const AppContainer = styled(AragonApp)`
  display: flex;
  align-items: center;
  justify-content: center;
`

export default class App extends React.Component {
  constructor () {
    super()

    this.app = new Aragon(
      new providers.WindowMessage(window.parent)
    )
    this.state = {}
    // ugly hack: aragon.js doesn't have handshakes yet
    // the wrapper is sending a message to the app before the app's ready to handle it
    // the iframe needs some time to set itself up,
    // so we put a timeout to wait for 5s before subscribing
    setTimeout(() => {
      this.setState({ state$: this.app.state() })
    }, 5000)
  }

  render () {
    console.log(this.app.increment)

    return (
      <AppContainer>
        <div>
          <ObservedCount observable={this.state.state$} />
          <Button onClick={() => this.app.decrement(1)}>Decrement</Button>
          <Button onClick={() => this.app.increment(1)}>Increment</Button>
        </div>
      </AppContainer>
    )
  }
}

const ObservedCount = observe(
  (state$) => state$,
  { count: 0 }
)(
  ({ count }) => <Text.Block style={{ textAlign: 'center' }} size='xxlarge'>{count}</Text.Block>
)
