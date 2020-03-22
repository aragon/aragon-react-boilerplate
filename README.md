# Aragon Buidler Boilerplate

> 🕵️ [Find more boilerplates using GitHub](https://github.com/search?q=topic:aragon-boilerplate) |
> ✨ [Official boilerplates](https://github.com/search?q=topic:aragon-boilerplate+org:aragon)

Buidler + React boilerplate for Aragon applications.

This boilerplate includes a fully working example app, complete with a background worker and a front-end in React (with Aragon UI).

_Note: This is an experimental boilerplate for developing Aragon applications. For a more stable boilerplate, please use aragon-react-boilerplate._

## Usage

To setup use the command `create-aragon-app`:

```sh
npx create-aragon-app <app-name> buidler
```

## Structure

This boilerplate has the following structure:

```md
root
├── app
├ ├── src
├ └── package.json
├── contracts
├ └── CounterApp.sol
├── test
├── arapp.json
├── manifest.json
├── buidler.config.js
└── package.json
```

- **app**: Frontend folder. Completely encapsulated, has its own package.json and dependencies.
  - **src**: Source files.
  - [**package.json**](https://docs.npmjs.com/creating-a-package-json-file): Frontend npm configuration file.
- **contracts**: Smart Contracts folder.
  - `CounterApp.sol`: Aragon app contract example.
- **test**: Tests folder.
- [**arapp.json**](https://hack.aragon.org/docs/cli-global-confg#the-arappjson-file): Aragon configuration file. Includes Aragon-specific metadata for your app.
- [**manifest.json**](https://hack.aragon.org/docs/cli-global-confg#the-manifestjson-file): Aragon configuration file. Includes web-specific configurations.
- [**buidler.config.js**](https://buidler.dev/config/): Buidler configuration file.
- [**package.json**](https://docs.npmjs.com/creating-a-package-json-file): Main npm configuration file.

## Running your app

To run the app in a browser with front end plus back end hot reloading, simply run `npm start`.

## What's in this boilerplate?

### npm Scripts

- **postinstall**: Runs after installing dependencies.
- **build-app**: Installs front end project (app/) dependencies.
- **start** Runs your app inside a DAO.
- **compile**: Compiles the smart contracts.
- **test**: Runs tests for the contracts.

### Hooks

These hooks are called by the Aragon Buidler plugin during the start task's lifecycle. Use them to perform custom tasks at certain entry points of the development build process, like deploying a token before a proxy is initialized, etc.

Link them to the main buidler config file (buidler.config.js) in the `aragon.hooks` property.

All hooks receive two parameters: 1) A params object that may contain other objects that pertain to the particular hook. 2) A "bre" or BuidlerRuntimeEnvironment object that contains enviroment objects like web3, Truffle artifacts, etc.

```
  // Called before a dao is deployed.
  preDao: async ({}, { web3, artifacts }) => {},

  // Called after a dao is deployed.
  postDao: async ({ dao }, { web3, artifacts }) => {},

  // Called after the app's proxy is created, but before it's initialized.
  preInit: async ({ proxy }, { web3, artifacts }) => {},

  // Called after the app's proxy is initialized.
  postInit: async ({ proxy }, { web3, artifacts }) => {},

  // Called when the start task needs to know the app proxy's init parameters.
  // Must return an array with the proxy's init parameters.
  getInitParams: async ({}, { web3, artifacts }) => {
    return []
  }
```

For an example on how to use these hooks, please see the [**token-wrapper tests**](https://github.com/aragon/buidler-aragon/blob/master/test/projects/token-wrapper/scripts/hooks.js) within the plugin's test projects.

### Libraries

- [**@aragon/os**](https://github.com/aragon/aragonos): Aragon interfaces.
- [**@aragon/api**](https://github.com/aragon/aragon.js/tree/master/packages/aragon-api): Wrapper for Aragon application RPC.
- [**@aragon/ui**](https://github.com/aragon/aragon-ui): Aragon UI components (in React).
- [**@aragon/buidler-aragon**](https://github.com/aragon/buidler-aragon): Aragon Buidler plugin.
