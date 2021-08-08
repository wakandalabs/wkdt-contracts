# Swap
### Freeze Sale
```
flow transactions send ./transactions/sale/freeze.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Unfreeze Sale
```
flow transactions send ./transactions/sale/unfreeze.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Deposit Wakanda Token by Admin
```
flow transactions send ./transactions/sale/depositWakandaToken.cdc \
  --network testnet \
  --arg UFix64:50000.0 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Withdraw tUSDT by Admin
```
flow transactions send ./transactions/sale/withdrawTusdt.cdc \
  --network testnet \
  --arg UFix64:50000.0 \
  --arg Address:0x03d1e02a48354e2b \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Update Lockup Schedule ID
```
flow transactions send ./transactions/sale/updateLockupScheduleId.cdc \
  --network testnet \
  --arg Int:1 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Purchase Wakanda Token
```
flow transactions send ./transactions/sale/purchaseWakandaToken.cdc \
  --network testnet \
  --arg UFix64:500.0 \
  --signer wkdt-user-testnet \
  --gas-limit 1000
```

### Distribute Wakanda Token to Purchaser
```
flow transactions send ./transactions/sale/distribute.cdc \
  --network testnet \
  --arg Address:0x67e7299327d1bf70 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Distribute Locked Wakanda Token to Purchaser in a Batch
```
flow transactions send ./transactions/sale/distributeBatch.cdc \
  --network testnet \
  --args-json "$(cat "./arguments/distribute.json")" \
  --signer wkdt-admin-new-testnet \
  --gas-limit 9999
```

### Refund tUSDT to Purchaser
```
flow transactions send ./transactions/sale/refund.cdc \
  --network testnet \
  --arg Address:0x95d4f57daf2fb5ce \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Refund tUSDT to Purchaser in a Batch
```
flow transactions send ./transactions/sale/refundBatch.cdc \
  --network testnet \
  --args-json "$(cat "./arguments/refund.json")" \
  --signer wkdt-admin-new-testnet \
  --gas-limit 9999
```
