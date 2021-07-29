# Vibranium Contracts
![Vibranium](Vibranium.svg)

The symbol of Vibranium is ∆, You can type ∆ by pressing "option + j" in Mac.

## Setup Flow CLI
https://docs.onflow.org/flow-cli/install

## Run Scripts/Transactions - Examples
### Setup Vibranium Vault
```
flow transactions send ./transactions/token/setupVibraniumVault.cdc \
  --network testnet \
  --signer vibranium-user-testnet \
  --gas-limit 1000
```

### Transfer Vibranium
```
flow transactions send ./transactions/token/transferVibranium.cdc \
  --network testnet \
  --arg UFix64:100.0 \
  --arg Address:0x03d1e02a48354e2b \
  --signer vibranium-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaPass Collection
```
flow transactions send ./transactions/token/setupWakandaPass.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Mint WakandaPass NFT
```
flow transactions send ./transactions/token/mintWakandaPass.cdc \
  --network testnet \
  --signer vibra-admin-testnet \
  --gas-limit 1000
```

### Get Vibranium Balance
```
flow scripts execute ./scripts/token/getVibraniumBalance.cdc \
  --network testnet \
  --arg Address:0x03d1e02a48354e2b
```

### Stake VIBRA into WakandaPass
```
flow transactions send ./transactions/staking/stakeNewVibra.cdc \
  --network testnet \
  --arg UFix64:1000.0 \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Get Staking Info
```
flow scripts execute ./scripts/staking/getStakingInfo.cdc \
  --network testnet \
  --arg Address:0x03d1e02a48354e2b
```

### Switch Epoch
```
flow transactions send ./transactions/staking/switchEpoch.cdc \
  --network testnet \
  --signer vibra-admin-testnet \
  --gas-limit 1000
```

