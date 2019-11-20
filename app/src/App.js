import React from 'react'
import { useAragonApi } from '@aragon/api-react'
import {
  Box,
  Button,
  GU,
  Header,
  IconMinus,
  IconPlus,
  Main,
  SyncIndicator,
  Tabs,
  textStyle,
} from '@aragon/ui'
import styled from 'styled-components'

function App() {
  const { api, appState } = useAragonApi()
  const { count, isSyncing } = appState
  console.log(count, isSyncing)
  return (
    <Main>
      {isSyncing && <SyncIndicator />}
      <Header
        primary="Counter"
        secondary={
          <>
            <Button
              display="icon"
              icon={<IconMinus />}
              label="Decrement"
              onClick={() => api.decrement(1).toPromise()}
            />
            <Button
              display="icon"
              icon={<IconPlus />}
              label="Increment"
              onClick={() => api.increment(1).toPromise()}
              css={`
                margin-left: ${2 * GU}px;
              `}
            />
          </>
        }
      />
      <Box
        css={`
          display: flex;
          align-items: center;
          justify-content: center;
          height: ${50 * GU}px;
          ${textStyle('title3')};
        `}
      >
        Count: {count}
      </Box>
    </Main>
  )
}

export default App
