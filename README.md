# WakandaToken Contracts
![WakandaToken](WakandaToken.svg)

The symbol of WakandaToken is ∆, You can type ∆ by pressing "option + j" in Mac.

## Setup Flow CLI
https://docs.onflow.org/flow-cli/install

## Run Scripts/Transactions - Examples
### Setup Wakanda Token Vault
```
flow transactions send ./transactions/token/setupWakandaTokenVault.cdc \
  --network testnet \
  --signer wakandaToken-user-testnet \
  --gas-limit 1000
```

### Transfer Wakanda Token
```
flow transactions send ./transactions/token/transferWakandaToken.cdc \
  --network testnet \
  --arg UFix64:100.0 \
  --arg Address:0x03d1e02a48354e2b \
  --signer wakandaToken-admin-testnet \
  --gas-limit 1000
```

### Setup Wakanda Pass Collection
```
flow transactions send ./transactions/token/setupWakandaPass.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Mint Wakanda Pass NFT
```
flow transactions send ./transactions/token/mintWakandaPass.cdc \
  --network testnet \
  --signer vibra-admin-testnet \
  --gas-limit 1000
```

### Get Wakanda Token Balance
```
flow scripts execute ./scripts/token/getWakandaTokenBalance.cdc \
  --network testnet \
  --arg Address:0x03d1e02a48354e2b
```

### Stake WKDT into WakandaPass
```
flow transactions send ./transactions/staking/stakeNewWkdt.cdc \
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

