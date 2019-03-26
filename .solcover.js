module.exports = {
    norpc: true,
    compileCommand: '../node_modules/.bin/truffle compile',
    testCommand: '../node_modules/.bin/truffle test --network coverage',
    copyPackages: [],
    skipFiles: [
        'test/TestImports.sol',
    ]
}
