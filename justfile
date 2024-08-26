default:
  @just --list

set dotenv-load
set fallback

defaultNativeCurrencyLabel := "RIA"
defaultWETH9Name := "Wrapped RIA"
defaultWETH9Symbol := "WRIA"

deploy-uniswapv3 nativeCurrencyLabel=defaultNativeCurrencyLabel:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(string)" \
    scripts/DeployUniswapV3.s.sol:DeployUniswapV3 \
    "{{ defaultNativeCurrencyLabel }}"

transfer-ownership new_owner:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(address)" \
    scripts/TransferOwnership.s.sol:TransferOwnership \
    "{{ new_owner }}"

deploy-weth9 name=defaultWETH9Name symbol=defaultWETH9Symbol:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(string,string)" \
    scripts/DeployWETH9.s.sol:DeployWETH9 \
    "{{ name }}" \
    "{{ symbol }}"

weth9-deposit amount:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(uint256)" \
    scripts/WETH9Deposit.s.sol:WETH9Deposit \
    {{ amount }}

deploy-erc20 name symbol max_supply decimals="18":
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(string,string,uint8,uint256)" \
    scripts/DeployERC20.s.sol:DeployERC20 \
    "{{ name }}" \
    "{{ symbol }}" \
    {{ decimals }} \
    {{ max_supply }}

deploy-pool tokenA tokenB fee sqrtPriceX96:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(address,address,uint24,uint160)" \
    scripts/DeployPool.s.sol:DeployPool \
    "{{ tokenA }}" \
    "{{ tokenB }}" \
    {{ fee }} \
    {{ sqrtPriceX96 }}

create-position tokenA tokenB tokenAAmount tokenBAmount fee:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(address,address,uint24,uint256,uint256)" \
    scripts/CreatePosition.s.sol:CreatePosition \
    "{{ tokenA }}" \
    "{{ tokenB }}" \
    {{ fee }} \
    {{ tokenAAmount }} \
    {{ tokenBAmount }}
