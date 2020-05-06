# Aragon Buidler Boilerplate

> 🕵️ [Find more boilerplates using GitHub](https://github.com/search?q=topic:aragon-boilerplate) |
> ✨ [Official boilerplates](https://github.com/search?q=topic:aragon-boilerplate+org:aragon)

> ▶️ To use this boilerplate, run `npx create-aragon-app <app-name>`

Buidler + React boilerplate for Aragon applications.

## Running your app

To run the app in a browser with frontend and contract hot-reloading, simply run `npm start`.

1. Add code quality tools, like JS and contract linting. You may also want to check existing [buidler plugins](https://buidler.dev/plugins/).
2. Develop your [AragonApp contract](https://hack.aragon.org/docs/aragonos-building)
3. Develop your [frontend](https://ui.aragon.org/getting-started/)
4. [Publish](https://hack.aragon.org/docs/guides-publish)!

## What's in this boilerplate?

### npm Scripts

- **postinstall**: Runs after installing dependencies.
- **build-app**: Installs front end project (app/) dependencies.
- **start** Runs your app inside a DAO.
- **compile**: Compiles the smart contracts.
- **test**: Runs tests for the contracts.
- **publish:major**: Releases a major version to aragonPM.
- **publish:minor**: Releases a minor version to aragonPM.
- **publish:patch**: Releases a patch version to aragonPM.

### Hooks

These hooks are called by the Aragon Buidler plugin during the start task's lifecycle. Use them to perform custom tasks at certain entry points of the development build process, like deploying a token before a proxy is initialized, etc.

Link them to the main buidler configuration file (buidler.config.js) in the `aragon.hooks` property.

All hooks receive two parameters: 1) A params object that may contain other objects that pertain to the particular hook. 2) A "bre" or BuidlerRuntimeEnvironment object that contains environment objects like web3, Truffle artifacts, etc.

```
// Called before a dao is deployed.
preDao: async ({ log }, { web3, artifacts }) => {},

// Called after a dao is deployed.
postDao: async ({ dao, _experimentalAppInstaller, log }, { web3, artifacts }) => {},

// Called after the app's proxy is created, but before it's initialized.
preInit: async ({ proxy, _experimentalAppInstaller, log  }, { web3, artifacts }) => {},

// Called after the app's proxy is initialized.
postInit: async ({ proxy, _experimentalAppInstaller, log  }, { web3, artifacts }) => {},

// Called when the start task needs to know the app proxy's init parameters.
// Must return an array with the proxy's init parameters.
getInitParams: async ({ log }, { web3, artifacts }) => {
  return []
}
```

If you want an example of how to use these hooks, please see the [plugin's own tests for an example project](https://github.com/aragon/buidler-aragon/blob/master/test/projects/token-wrapper/scripts/hooks.js).

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

- **app**: Frontend folder. Completely encapsulated: has its own package.json and dependencies.
  - **src**: Source files.
  - [**package.json**](https://docs.npmjs.com/creating-a-package-json-file): Frontend npm configuration file.
- **contracts**: Smart contracts folder.
  - `CounterApp.sol`: AragonApp contract example.
- **test**: Tests folder.
- [**arapp.json**](https://hack.aragon.org/docs/cli-global-confg#the-arappjson-file): Aragon configuration file. Includes Aragon-specific metadata for your app.
- [**manifest.json**](https://hack.aragon.org/docs/cli-global-confg#the-manifestjson-file): Aragon configuration file. Includes web-specific configuration.
- [**buidler.config.js**](https://buidler.dev/config/): Buidler configuration file.
- [**package.json**](https://docs.npmjs.com/creating-a-package-json-file): Main npm configuration file.

### Libraries

- [**@aragon/os**](https://github.com/aragon/aragonos): AragonApp smart contract interfaces.
- [**@aragon/api**](https://github.com/aragon/aragon.js/tree/master/packages/aragon-api): Aragon client application API.
- [**@aragon/ui**](https://github.com/aragon/aragon-ui): Aragon UI components (in React).
- [**@aragon/buidler-aragon**](https://github.com/aragon/buidler-aragon): Aragon Buidler plugin.
