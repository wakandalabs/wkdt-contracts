# Staking
### Stake Wakanda Token into WakandaPass
```
flow transactions send ./transactions/staking/stakeNewWakandaTokens.cdc \
  --network testnet \
  --arg UFix64:1000.0 \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Stake Wakanda Token that is Already in Wakanda Pass
```
flow transactions send ./transactions/staking/stakeNewWakandaTokensFromPass.cdc \
  --network testnet \
  --arg UFix64:1000.0 \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Set Epoch Token Payout
```
flow transactions send ./transactions/staking/setEpochWakandaTokenPayout.cdc \
  --network testnet \
  --arg UFix64:1000.0 \
  --signer wkdt-mining-testnet \
  --gas-limit 1000
```

### Switch Epoch
```
flow transactions send ./transactions/staking/switchEpoch.cdc \
  --network testnet \
  --signer wkdt-mining-testnet \
  --gas-limit 1000
```