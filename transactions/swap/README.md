# Swap
### Freeze Swap Pair
```
flow transactions send ./transactions/swap/freeze.cdc \
  --network testnet \
  --signer wkdt-swap-testnet \
  --gas-limit 1000
```

### Unfreeze Swap Pair
```
flow transactions send ./transactions/swap/unfreeze.cdc \
  --network testnet \
  --signer wkdt-swap-testnet \
  --gas-limit 1000
```

### Add Initial Liquidity
```
flow transactions send ./transactions/swap/addLiquidityByAdmin.cdc \
  --network testnet \
  --arg UFix64:10000.0 \
  --arg UFix64:10000.0 \
  --signer wkdt-swap-testnet \
  --gas-limit 1000
```
