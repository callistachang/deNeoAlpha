# de Neo Alpha:dna:

Personal references:

- https://hardhat.org/tutorial/writing-and-compiling-contracts.html

```
# Compile contracts (generates /artifacts and /cache)
npx hardhat compile

# Test contracts
npx hardhat test

# Run Hardhat's testing network, something like ganache-cli
npx hardhat node

# Runs a script against an embedded instance of Hardhat Network
npx hardhat run scripts/deploy.js

# Runs a script against Hardhat's testing network
npx hardhat run scripts/deploy.js --network localhost

# Runs a script in a certain network (defined in hardhat.config.js)
npx hardhat run scripts/deploy.js --network <network-name>
```
