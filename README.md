# Aragon React Boilerplate

> 🕵️ [Find more boilerplates using GitHub](https://github.com/search?q=topic:aragon-boilerplate) | 
> ✨ [Official boilerplates](https://github.com/search?q=topic:aragon-boilerplate+org:aragon)

React boilerplate for Aragon applications.

This boilerplate also includes a fully working example app, complete with a background worker and a front-end in React (with Aragon UI).

## Usage

```sh
aragon init app.aragonpm.eth react
```

## Running your app

### Using HTTP

Running your app using HTTP will allow for a faster development process of your app's front-end, as it can be hot-reloaded without the need to execute `aragon run` every time a change is made.

- First start your app's development server running `npm run start:app`, and keep that process running. By default it will rebuild the app and reload the server when changes to the source are made.

- After that, you can run `npm run start:aragon:http` which will compile your app's contracts, publish the app locally and create a DAO. You will need to stop it and run it again after making changes to your smart contracts.

Changes to the app's background script (`app/script.js`) cannot be hot-reloaded, after making changes to the script, you will need to either restart the development server (`npm run start:app`) or rebuild the script `npm run build:script`.

### Using IPFS

Running your app using IPFS will mimic the production environment that will be used for running your app. `npm run start:aragon:ipfs` will run your app using IPFS. Whenever a change is made to any file in your front-end, a new version of the app needs to be published, so the command needs to be restarted.

## What's in the box?

### npm Scripts

- **start** or **start:aragon:ipfs**: Runs your app inside a DAO served from IPFS
- **start:aragon:http**: Runs your app inside a DAO served with HTTP (hot reloading)
- **start:app**: Starts a development server for your app
- **compile**: Compile the smart contracts
- **build**: Builds the front-end and background script
- **build:app**: Builds the front-end
- **build:script**: Builds the background script
- **test**: Runs tests for the contracts
- **publish:patch**: Release a patch version to aragonPM (only frontend/content changes allowed)
- **publish:minor**: Release a minor version to aragonPM (only frontend/content changes allowed)
- **publish:major**: Release a major version to aragonPM (frontend **and** contract changes)
- **versions**: Check the currently installed versions of the app

### Libraries

- [**@aragon/os**](https://github.com/aragon/aragonos): Aragon interfaces
- [**@aragon/client**](https://github.com/aragon/aragon.js/tree/master/packages/aragon-client): Wrapper for Aragon application RPC
- [**@aragon/ui**](https://github.com/aragon/aragon-ui): Aragon UI components (in React)

## Publish

This app has 3 environments defined in `arapp.json`:

| Environment   | Network   |
|---            |---        |
| default       | localhost |
| staging       | rinkeby   |
| production    | mainnet   |

Prerequisites:
- ENS Registry address

Note: the `default` environment which points to `localhost` does not have an ENS Registry address specified because the `@aragon/cli` will default the value to `0xB9462EF3441346dBc6E49236Edbb0dF207db09B7` (the ENS Registry pre-deployed on the local development chain).

### Introduction to environments

Environments are defined in `arapp.json`, for example `staging` points to:
- an ENS registry (`0x314159265dd8dbb310642f98f50c066173c1259b`)
- an APM registry (`open.aragonpm.eth`)
- an APM repository (`app`)
- an Ethereum network (`rinkeby`)
- an Ethereum websockets provider (`wss://rinkeby.eth.aragon.network/ws` - to **read** from the blockchain)

The `rinkeby` network is further defined in `truffle.js`, and has:
- an Ethereum provider (to **write** to the blockchain):
    - an address (`https://rinkeby.infura.io`)
    - an Ethereum Account (`0xb4124cEB3451635DAcedd11767f004d8a28c6eE7`)
    (which is the first account generated from the `DEFAULT_MNEMONIC` variable, to use a different account see [here](#Using-a-different-Ethereum-account))

### Major version: content + contract

Command:
```
npm run publish:major -- --environment staging
```

This will:
1. _build_ the app's frontend (the output lives in `dist`)
2. _compile_ the app's contract (the output lives in `build`)
3. publish the app to the **staging** environment.

Sample output:
```
 > aragon apm publish major "--environment" "staging"

 ✔ Successfully published app.open.aragonpm.eth v1.0.0: 
 ℹ Contract address: 0xE636bcA5B95e94F749F63E322a04DB59362299F1
 ℹ Content (ipfs): QmR695Wu5KrHNec7pRP3kPvwYihABDAyVYdX5D5vwLgxCn
 ℹ Transaction hash: 0x3d752db29cc106e9ff98b260a90615921eb32471425a29ead8cbb830fb224d8
```

Note: the contract location is defined in `arapp.json` under `path`.
Note: you can also deploy a major version with only frontend changes by passing `--only-content`.

### Minor/patch version: content only

Command:
```
npm run publish:patch -- --environment staging
```

This will:
1. _build_ the app's frontend (which lives in `dist`)
2. publish the app to the **staging** environment.

Sample output:
```
 ✔ Successfully published app.open.aragonpm.eth v1.1.1: 
 ℹ Contract address: 0xE636bcA5B95e94F749F63E322a04DB59362299F1
 ℹ Content (ipfs): QmUYv9cjyNVxCyAJGK2YXjkbzh6u4iW2ak81Z9obdefM1q
 ℹ Transaction hash: 0x57864d8efd8d439008621b494b19a3e8f876a8a46b38475f9626802f0a1403c2
```

### Check published versions

Command:
```
npm run versions -- --environment staging
```

Sample output:
```
 ℹ app.open.aragonpm.eth has 4 published versions
 ✔ 1.0.0: 0xE636bcA5B95e94F749F63E322a04DB59362299F1 ipfs:QmR695Wu5KrHNec7pRP3kPvwYihABDAyVYdX5D5vwLgxCn
 ✔ 1.1.0: 0xE636bcA5B95e94F749F63E322a04DB59362299F1 ipfs:QmSwjUZFpv2c2e9fLoxtgFrAsAmBN4DyQGJp4RcqQcW3z3
 ✔ 1.1.1: 0xE636bcA5B95e94F749F63E322a04DB59362299F1 ipfs:QmUYv9cjyNVxCyAJGK2YXjkbzh6u4iW2ak81Z9obdefM1q
 ✔ 2.0.0: 0x74CBbbC932d7C344FCd789Eba24BfD40e52980c9 ipfs:Qmadb3hzwLDKtb93fF367Vg1epkdsLZF4dhpapNYynjgZF
```

### Using a different Ethereum account

To deploy from a different account, you can:
- define a `~/.aragon/mnemonic.json` file
    ```
    {
        "mnemonic": "explain tackle mirror kit ..."
    }
    ```
    or
- define a `~/.aragon/${network_name}_key.json` file, for example: `~/.aragon/rinkeby_key.json`
    ```
    {
        "keys": [
            "a8a54b2d8197bc0b19bb8a084031be71835580a01e70a45a13babd16c9bc1563"
        ]
    }
    ```
