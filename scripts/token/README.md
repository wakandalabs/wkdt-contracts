# Token
### Get Predefined Lockup Schedule
```
flow scripts execute ./scripts/token/getPredefinedLockupSchedule.cdc \
  --network testnet \
  --arg Int:0
```

### Get WakandaToken Balance
```
flow scripts execute ./scripts/token/getWakandaTokenBalance.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get Idle WakandaToken Balance in WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassVaultBalance.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get Total WakandaToken Balance in WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassTotalBalance.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get WakandaToken Lockup Schedule in WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassLockupSchedule.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get WakandaToken Lockup Amount in WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassLockupAmount.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get Metadata from WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassMetadata.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Get Original Owner from WakandaPass
```
flow scripts execute ./scripts/token/getWakandaPassOriginalOwner.cdc \
  --network testnet \
  --arg Address:0x457df669b4f4d1a4
```

### Check account initialized
```
flow scripts execute ./scripts/token/isAccountInitialized.cdc \
    --network testnet \
    --arg Address:0x457df669b4f4d1a4
```