#Ethereum Smart Contracts for SMaker

## Test locally

    npm install -g ganache-cli
    npm install
    ganache-cli
    npm test

## Deploy locally

* Start testrpc ```ganache-cli -e 10000```
* Deploy the contracts using truffle: ```truffle migrate```
* Then launch truffle console to play with the contracts: ```truffle console```

## Deploy on remix
```npm install -g truffle-flattener```
```truffle-flattener contracts/**/*.sol```

## Deploy on test net (Ropsten)

The fastest way is to use Metamask rather than running your own node.

## Deploy on live net

## Security

See https://consensys.github.io/smart-contract-best-practices/
