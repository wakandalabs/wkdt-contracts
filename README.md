# WakandaToken Contracts
The symbol of WakandaToken is ₩ or $WKDT.

## Setup Flow CLI
https://docs.onflow.org/flow-cli/install

## Run Scripts/Transactions - Examples
### Setup WakandaToken Vault
```
flow transactions send ./transactions/token/setupWakandaTokenVault.cdc \
  --network testnet \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Transfer WakandaToken
```
flow transactions send ./transactions/token/transferWakandaToken.cdc \
  --network testnet \
  --arg UFix64:100.0 \
  --arg Address:0x57df669b4f4d1a4 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaPass Collection
```
flow transactions send ./transactions/token/setupWakandaPassCollection.cdc \
  --network testnet \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Mint WakandaPass NFT
```
flow transactions send ./transactions/token/mintWakandaPass.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Get WakandaToken Balance
```
flow scripts execute ./scripts/token/getWakandaTokenBalance.cdc \
  --network testnet \
  --arg Address:0x57df669b4f4d1a4
```

### Stake WKDT into WakandaPass
```
flow transactions send ./transactions/staking/stakeNewWkdt.cdc \
  --network testnet \
  --arg UFix64:1000.0 \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Get Staking Info
```
flow scripts execute ./scripts/staking/getStakingInfo.cdc \
  --network testnet \
  --arg Address:0x57df669b4f4d1a4
```

### Switch Epoch
```
flow transactions send ./transactions/staking/switchEpoch.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

