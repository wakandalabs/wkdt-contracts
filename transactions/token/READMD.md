# Token
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
  --arg UFix64:1000.0 \
  --arg Address:0x2e98439d54ec3699 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaPass Collection
```
flow transactions send ./transactions/token/setupWakandaPassCollection.cdc \
  --network testnet \
  --signer wkdt-user2-testnet \
  --gas-limit 1000
```

### Withdraw All Unlocked Tokens from WakandaPass
```
flow transactions send ./transactions/token/withdrawAllFromWakandaPass.cdc \
  --network testnet \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Setup tUSDT Vault
```
flow transactions send ./transactions/token/setupTeleportedTetherTokenVault.cdc \
  --network testnet \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Setup all account
```
flow transactions send ./transactions/token/setupAllAccount.cdc \
  --network testnet \
  --signer wkdt-user2-testnet \
  --gas-limit 1000
```
