# Token
### Setup Vibranium Vault
```
flow transactions send ./transactions/token/setupVibraniumVault.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Transfer Vibranium
```
flow transactions send ./transactions/token/transferVibranium.cdc \
  --network testnet \
  --arg UFix64:100.0 \
  --arg Address:0x03d1e02a48354e2b \
  --signer vibra-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaPass Collection
```
flow transactions send ./transactions/token/setupWakandaPassCollection.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Withdraw All Unlocked Tokens from WakandaPass
```
flow transactions send ./transactions/token/withdrawAllFromWakandaPass.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```

### Setup tUSDT Vault
```
flow transactions send ./transactions/token/setupTeleportedTetherTokenVault.cdc \
  --network testnet \
  --signer vibra-user-testnet \
  --gas-limit 1000
```