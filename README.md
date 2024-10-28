# Astria Uniswap

This project contains Uniswap related smart contracts and deployment scripts

Make sure you have the following installed:

  * npm
  * [Foundry + Forge](https://book.getfoundry.sh/getting-started/installation)

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/astriaorg/uniswap.git
   cd uniswap
   ```

2. Initialize git submodules:
   ```
   git submodule update --init --recursive
   ```

3. Install dependencies:
   ```
   npm i
   ```

4. Set up environment variables:
   Copy the `.env.example` file to `.env` in the root directory:
   ```
   cp .env.example .env
   ```
   Then open the `.env` file and update the values according to your requirements.

## Deploying Uniswap V3

1. Deploy WTIA9 (weth9 based contract):
   ```
   just deploy-wtia9
   ```
   Optionally, customize name and symbol:
   ```
   just deploy-wtia9 "Custom Wrapped Token" "CWRIA"
   ```

2. Deploy Uniswap V3 Core:
   ```
   just deploy-uniswapv3
   ```
   To use a different native currency label (default is "RIA"):
   ```
   just deploy-uniswapv3 "CUSTOM"
   ```

3. (Optional) Transfer Ownership:
   ```
   just transfer-ownership <new_owner_address>
   ```

Deployment details are saved to the file specified in the `DEPLOY_JSON` environment variable.

Note: Ensure proper configuration of `PRIVATE_KEY` and `JSON_RPC` in the `.env` file before deployment.

## Deploying a Token

To deploy a new ERC20 token:

1. Use the `deploy-erc20` command:
   ```
   just deploy-erc20 <name> <symbol> <total_supply> [decimals]
   ```
   Parameters:
   - `<name>`: Token's full name (e.g., "My Custom Token")
   - `<symbol>`: Token's symbol (e.g., "MCT")
   - `<total_supply>`: Total token supply in human-readable format
   - `[decimals]`: (Optional) Token decimal places (default: 18)

   Example:
   ```
   just deploy-erc20 "My Custom Token" MCT 1000000 6
   ```
   This deploys a token with 1 million total supply and 6 decimal places.

2. Note the deployed token address for future interactions.

Note: The `deploy-erc20` command automatically adjusts for decimals, so input the total supply as a human-readable number. For instance, to deploy 1 million tokens with 18 decimals, simply use 1000000 as the total supply.

## Making a WTIA9 Deposit

To deposit native currency (e.g., RIA) into the WTIA9 contract and receive wrapped tokens:

1. Ensure you have deployed the WTIA9 contract using the `deploy-wtia9` command as described earlier.

2. Use the `wtia9-deposit` command:
   ```
   just wtia9-deposit <amount>
   ```
   Parameter:
   - `<amount>`: The amount of native currency to deposit, in wei.

   Example:
   ```
   just wtia9-deposit 1000000000000000000
   ```
   This deposits 1 native token (assuming 18 decimal places).

3. The command will execute a transaction to deposit the specified amount into the WTIA9 contract.

4. Upon successful execution, you will receive an equivalent amount of wrapped tokens (e.g., WRIA).

Note: Ensure you have sufficient native currency in your account to cover both the deposit amount and the transaction fee.

## Available Commands

### Justfile Commands

Run these commands using `just <command>`:

- `deploy-uniswapv3 [nativeCurrencyLabel]`: Deploy UniswapV3 contracts (default nativeCurrencyLabel: "RIA")
- `transfer-ownership <new_owner>`: Transfer ownership of contracts
- `deploy-wtia9 [name] [symbol]`: Deploy WTIA9 contract (default name: "Wrapped RIA", default symbol: "WRIA")
- `wtia9-deposit <amount>`: Deposit into WTIA9 contract
- `deploy-erc20 <name> <symbol> <max_supply> [decimals]`: Deploy ERC20 token (default decimals: 18)
- `deploy-pool <tokenA> <tokenB> <fee> <sqrtPriceX96>`: Deploy a new Uniswap V3 pool
- `create-position <tokenA> <tokenB> <tokenAAmount> <tokenBAmount> <fee>`: Create a new position in a Uniswap V3 pool
- `swap <tokenIn> <tokenOut> <fee> <amountIn>`: Execute a token swap on Uniswap V3

### NPM Scripts

Run these commands using `npm run <script>`:

- `prettier`: Format Solidity files
- `prettier:check`: Check Solidity file formatting
- `solhint`: Lint Solidity files and fix issues
- `solhint:check`: Check Solidity files for linting issues
- `lint`: Run both prettier and solhint with fixes
- `lint:check`: Check both formatting and linting without fixes
