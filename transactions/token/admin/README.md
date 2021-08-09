# Token
### Setup Community Sale Lockup Schedule
```
flow transactions send ./transactions/token/admin/setupCommunitySaleSchedule.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Mint WakandaPass NFT
```
flow transactions send ./transactions/token/admin/mintWakandaPass.cdc \
  --network testnet \
  --arg Address:0x95d4f57daf2fb5ce \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Mint WakandaPass NFT with Custom Lockup Schedule
```
flow transactions send ./transactions/token/admin/mintWakandaPassWithCustomLockup.cdc \
  --network testnet \
  --arg Address:0x95d4f57daf2fb5ce \
  --arg UFix64:500.0 \
  --arg UFix64:1625654520.0 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Mint WakandaPass NFT with Predefined Lockup Schedule
```
flow transactions send ./transactions/token/admin/mintWakandaPassWithCustomLockup.cdc \
  --network testnet \
  --arg Address:0x95d4f57daf2fb5ce \
  --arg UFix64:500.0 \
  --arg Int:0 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaToken Minter
```
flow transactions send ./transactions/token/admin/setupWakandaTokenMinter.cdc \
  --network testnet \
  --arg UFix64:1000000000.0 \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```

### Setup WakandaToken Minter for Staking
```
flow transactions build ./transactions/token/admin/setupWakandaTokenMinterForStaking.cdc \
  --network testnet \
  --arg UFix64:1000000000.0 \
  --proposer 0xccc5c610f25031c9 \
  --proposer-key-index 0 \
  --authorizer 0xccc5c610f25031c9 \
  --authorizer 0x4e57c4f07871af8d \
  --payer 0x4e57c4f07871af8d \
  --gas-limit 1000 \
  -x payload \
  --save ./build/unsigned.rlp

flow transactions sign ./build/unsigned.rlp \
  --signer wkdt-admin-testnet \
  --filter payload \
  --save ./build/signed-1.rlp

flow transactions sign ./build/signed-1.rlp \
  --signer wkdt-mining-testnet \
  --filter payload \
  --save ./build/signed-2.rlp

flow transactions send-signed --network testnet ./build/signed-2.rlp
```

### Create Public Minter
```
flow transactions send ./transactions/token/admin/setupWakandaPassMinterPublic.cdc \
  --network testnet \
  --signer wkdt-admin-testnet \
  --gas-limit 1000
```
