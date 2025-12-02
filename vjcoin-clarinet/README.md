# vjcoin-clarinet

A Clarinet project for the **VJCOIN** fungible token smart contract, written in Clarity.

## Project layout

This directory was generated with `clarinet new vjcoin-clarinet` and then extended:

- `Clarinet.toml` – Clarinet project configuration
- `contracts/`
  - `vjcoin.clar` – VJCOIN fungible token contract
- `tests/`
  - `vjcoin.test.ts` – placeholder test file (you can extend this with real tests)
- `settings/` – network configuration for Mainnet, Testnet, Devnet
- `package.json`, `tsconfig.json`, `vitest.config.ts` – TypeScript + Vitest test tooling

## Requirements

- Node.js and npm (for running TypeScript tests)
- Clarinet CLI (already installed):

  ```bash
  clarinet --version
  ```

## Useful commands

All commands below assume you are in this directory:

```bash
cd vjcoin-clarinet
```

### 1. Check contract syntax

```bash
clarinet check
```

This will parse and type-check all contracts in `contracts/`.

### 2. Open a Clarinet console (REPL)

```bash
clarinet console
```

From the console you can call contract functions, for example:

```clarity
(contract-call? .vjcoin mint u1000 'ST3AM1C1E2AMPLE000000000000000000000000000)
(contract-call? .vjcoin get-balance 'ST3AM1C1E2AMPLE000000000000000000000000000)
```

### 3. Run tests

Install dependencies once:

```bash
npm install
```

Then run the tests:

```bash
npm test
```

You can edit `tests/vjcoin.test.ts` to add unit tests for minting, transferring, and burning VJCOIN.

## vjcoin contract overview

The contract is defined in `contracts/vjcoin.clar` and includes:

- `define-fungible-token vjcoin` – declares the VJCOIN token
- `token-owner` – the principal allowed to mint new tokens (initially the deployer)
- `total-supply` – total number of tokens in existence
- `balances` – map of account balances

### Public functions

- `mint (amount uint) (recipient principal)`
  - Only `token-owner` can call this
  - Increases `total-supply` and the `recipient` balance

- `transfer (amount uint) (recipient principal)`
  - Called by a token holder to send tokens from their own balance
  - Fails if the caller has insufficient balance

- `burn (amount uint)`
  - Called by a token holder to destroy some of their own tokens
  - Decreases both the holder's balance and `total-supply`

### Read-only functions

- `get-balance (who principal)` – returns the balance for an address
- `get-total-supply` – returns the current total supply
- `get-name` – returns the token name (`"VJ Coin"`)
- `get-symbol` – returns the token symbol (`"VJCOIN"`)
- `get-decimals` – returns the number of decimal places (`u6`)

## Deployment notes

You can use Clarinet Devnet or Testnet for deployment workflows. At a high level:

1. Configure the desired network in `settings/`.
2. Use `clarinet integrate` or `clarinet devnet start` for local Devnet workflows.
3. When ready, deploy the contract using the Stacks blockchain tooling that integrates with Clarinet settings.

Refer to the official Clarinet documentation for detailed deployment instructions:
https://docs.hiro.so/clarinet
