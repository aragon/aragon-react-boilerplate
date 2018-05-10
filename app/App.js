import React from 'react'
import {
  AragonApp,
  Button,
  Text,

  observe
} from '@aragon/ui'
import Aragon, { providers } from '@aragon/client'

export default class App extends React.Component {
  constructor () {
    super()

    this.app = new Aragon(
      new providers.WindowMessage(window.parent)
    )
    this.state$ = this.app.state()
  }

  render () {
    return (
      <AragonApp backgroundLogo>
        <Button onClick={this.decrement.bind(this)} mode='strong' emphasis='negative'>-</Button>
        <ObservedCount observable={this.state$} />
        <Button onClick={this.increment.bind(this)} mode='strong' emphasis='positive'>+</Button>
      </AragonApp>
    )
  }

  increment () {
    this.app.decrement(1)
  }

  decrement () {
    this.app.increment(1)
  }
}

const ObservedCount = observe(
  (state$) => state$,
  { count: 0 }
)(
  ({ count }) => <Text size='xxlarge'>{count}</Text>
)
