default:
  @just --list

set dotenv-load
set fallback

defaultNativeCurrencyLabel := "TIA"
defaultWTIA9Name := "Wrapped Celestia"
defaultWTIA9Symbol := "WTIA"

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

deploy-wtia9 name=defaultWTIA9Name symbol=defaultWTIA9Symbol:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(string,string)" \
    scripts/DeployWTIA9.s.sol:DeployWTIA9 \
    "{{ name }}" \
    "{{ symbol }}"

wtia9-deposit amount:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(uint256)" \
    scripts/WTIA9Deposit.s.sol:WTIA9Deposit \
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

swap tokenIn tokenOut fee amountIn:
  forge script \
    --private-key {{ env_var('PRIVATE_KEY') }} \
    --rpc-url {{ env_var('JSON_RPC') }} \
    --broadcast \
    --skip-simulation \
    --slow \
    --priority-gas-price 1 \
    --sig "run(address,address,uint24,uint256)" \
    scripts/Swap.s.sol:Swap \
    "{{ tokenIn }}" \
    "{{ tokenOut }}" \
    {{ fee }} \
    {{ amountIn }}

verify-wtia9 name=defaultWTIA9Name symbol=defaultWTIA9Symbol:
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor(string,string)" "{{ name }}" "{{ symbol }}") \
    $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) \
    contracts/WTIA9.sol:WTIA9 \
    --skip-is-verified-check \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-v3-core-factory:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor()") \
    $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-core/contracts/UniswapV3Factory.sol:UniswapV3Factory \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-v3-pool poolAddress:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor()") \
    {{ poolAddress }} \
    lib/v3-core/contracts/UniswapV3Pool.sol:UniswapV3Pool \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-multicall2:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor()") \
    $(jq -r .multicall2Address {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/lens/UniswapInterfaceMulticall.sol:UniswapInterfaceMulticall \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-proxy-admin:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor()") \
    $(jq -r .proxyAdminAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/openzeppelin-contracts/contracts/proxy/ProxyAdmin.sol:ProxyAdmin \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-tick-lens:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode "constructor()") \
    $(jq -r .tickLensAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/lens/TickLens.sol:TickLens \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-nft-position-descriptor nativeCurrencyLabel=defaultNativeCurrencyLabel:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,bytes32)" \
      $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) \
      $(cast format-bytes32-string "{{ nativeCurrencyLabel }}")) \
    $(jq -r .nftPositionDescriptorAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol:NonfungibleTokenPositionDescriptor \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-proxy-descriptor:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address,bytes)" \
      $(jq -r .nftPositionDescriptorAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .proxyAdminAddress {{ env_var('DEPLOY_JSON') }}) \
      "0x") \
    $(jq -r .descriptorProxyAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/openzeppelin-contracts/contracts/proxy/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-nft-position-manager:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address,address)" \
      $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .nftPositionDescriptorAddress {{ env_var('DEPLOY_JSON') }}) ) \
    $(jq -r .nftPositionManagerAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/NonfungiblePositionManager.sol:NonfungiblePositionManager \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-v3-migrator:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address,address)" \
      $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .nftPositionManagerAddress {{ env_var('DEPLOY_JSON') }}) ) \
    $(jq -r .v3MigratorAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/V3Migrator.sol:V3Migrator \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-v3-staker:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address,uint256,uint256)" \
      $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .nftPositionManagerAddress {{ env_var('DEPLOY_JSON') }}) \
      $(cast --to-uint256 2592000) \
      $(cast --to-uint256 63072000)) \
    $(jq -r .v3StakerAddress {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-staker/contracts/UniswapV3Staker.sol:UniswapV3Staker \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-quoter-v2:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address)" \
      $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) ) \
    $(jq -r .quoterV2Address {{ env_var('DEPLOY_JSON') }}) \
    lib/v3-periphery/contracts/lens/QuoterV2.sol:QuoterV2 \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api

verify-swap-router-2:
  FOUNDRY_PROFILE=uniswap \
  forge verify-contract \
    --chain-id $(cast chain-id --rpc-url {{ env_var('JSON_RPC') }}) \
    --constructor-args $(cast abi-encode \
      "constructor(address,address,address,address)" \
      "0x0000000000000000000000000000000000000000" \
      $(jq -r .v3CoreFactoryAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .nftPositionManagerAddress {{ env_var('DEPLOY_JSON') }}) \
      $(jq -r .weth9Address {{ env_var('DEPLOY_JSON') }}) ) \
    $(jq -r .swapRouter02Address {{ env_var('DEPLOY_JSON') }}) \
    lib/swap-router-contracts/contracts/SwapRouter02.sol:SwapRouter02 \
    --verifier blockscout \
    --verifier-url {{ env_var('BLOCKSCOUT_URL') }}/api
