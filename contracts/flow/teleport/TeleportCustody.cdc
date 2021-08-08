import FungibleToken from "../token/FungibleToken.cdc"
import WakandaToken from "../token/WakandaToken.cdc"

pub contract TeleportCustody {
  pub var isFrozen: Bool

  pub let TeleportAdminStoragePath: StoragePath

  pub let TeleportAdminTeleportUserPath: PublicPath

  pub let TeleportAdminTeleportControlPath: PrivatePath

  pub let teleportAddressLength: Int

  pub let teleportTxHashLength: Int

  access(contract) let lockVault: @WakandaToken.Vault

  pub var unlocked: {String: Bool}

  pub event TeleportAdminCreated(allowedAmount: UFix64)

  pub event Locked(amount: UFix64, to: [UInt8])

  pub event Unlocked(amount: UFix64, from: [UInt8], txHash: String)

  pub event FeeCollected(amount: UFix64, type: UInt8)

  pub resource Allowance {
    pub var balance: UFix64

    init(balance: UFix64) {
      self.balance = balance
    }
  }

  pub resource Administrator {

    pub fun createNewTeleportAdmin(allowedAmount: UFix64): @TeleportAdmin {
      emit TeleportAdminCreated(allowedAmount: allowedAmount)
      return <- create TeleportAdmin(allowedAmount: allowedAmount)
    }

    pub fun freeze() {
      TeleportCustody.isFrozen = true
    }

    pub fun unfreeze() {
      TeleportCustody.isFrozen = false
    }

    pub fun createAllowance(allowedAmount: UFix64): @Allowance {
      return <- create Allowance(balance: allowedAmount)
    }
  }

  pub resource interface TeleportUser {
    pub var lockFee: UFix64

    pub var unlockFee: UFix64

    pub var allowedAmount: UFix64

    pub fun lock(from: @FungibleToken.Vault, to: [UInt8])

    pub fun depositAllowance(from: @Allowance)
  }

  pub resource interface TeleportControl {
    pub fun unlock(amount: UFix64, from: [UInt8], txHash: String): @FungibleToken.Vault

    pub fun withdrawFee(amount: UFix64): @FungibleToken.Vault

    pub fun updateLockFee(fee: UFix64)

    pub fun updateUnlockFee(fee: UFix64)
  }

  pub resource TeleportAdmin: TeleportUser, TeleportControl {
    pub var lockFee: UFix64

    pub var unlockFee: UFix64

    pub var allowedAmount: UFix64

    pub let feeCollector: @WakandaToken.Vault

    pub fun lock(from: @FungibleToken.Vault, to: [UInt8]) {
      pre {
        !TeleportCustody.isFrozen: "Teleport service is frozen"
        to.length == TeleportCustody.teleportAddressLength: "Teleport address should be teleportAddressLength bytes"
      }

      let vault <- from as! @WakandaToken.Vault
      let fee <- vault.withdraw(amount: self.lockFee)

      self.feeCollector.deposit(from: <-fee)

      let amount = vault.balance
      TeleportCustody.lockVault.deposit(from: <-vault)

      emit Locked(amount: amount, to: to)
      emit FeeCollected(amount: self.lockFee, type: 0)
    }

    pub fun unlock(amount: UFix64, from: [UInt8], txHash: String): @FungibleToken.Vault {
      pre {
        !TeleportCustody.isFrozen: "Teleport service is frozen"
        amount <= self.allowedAmount: "Amount unlocked must be less than the allowed amount"
        amount > self.unlockFee: "Amount unlocked must be greater than unlock fee"
        from.length == TeleportCustody.teleportAddressLength: "Teleport address should be teleportAddressLength bytes"
        txHash.length == TeleportCustody.teleportTxHashLength: "Teleport tx hash should be teleportTxHashLength bytes"
        !(TeleportCustody.unlocked[txHash] ?? false): "Same unlock txHash has been executed"
      }
      self.allowedAmount = self.allowedAmount - amount

      TeleportCustody.unlocked[txHash] = true
      emit Unlocked(amount: amount, from: from, txHash: txHash)

      let vault <- TeleportCustody.lockVault.withdraw(amount: amount)
      let fee <- vault.withdraw(amount: self.unlockFee)

      self.feeCollector.deposit(from: <-fee)
      emit FeeCollected(amount: self.unlockFee, type: 1)

      return <- vault
    }

    pub fun withdrawFee(amount: UFix64): @FungibleToken.Vault {
      return <- self.feeCollector.withdraw(amount: amount)
    }

    pub fun updateLockFee(fee: UFix64) {
      self.lockFee = fee
    }

    pub fun updateUnlockFee(fee: UFix64) {
      self.unlockFee = fee
    }

    pub fun getFeeAmount(): UFix64 {
      return self.feeCollector.balance
    }

    pub fun depositAllowance(from: @Allowance) {
      self.allowedAmount = self.allowedAmount + from.balance

      destroy from
    }

    init(allowedAmount: UFix64) {
      self.allowedAmount = allowedAmount

      self.feeCollector <- WakandaToken.createEmptyVault() as! @WakandaToken.Vault
      self.lockFee = 3.0
      self.unlockFee = 0.01
    }

    destroy() {
      destroy self.feeCollector
    }
  }

  pub fun getLockVaultBalance(): UFix64 {
    return TeleportCustody.lockVault.balance
  }

  init(teleportAddressLength: Int, teleportTxHashLength: Int) {
    self.isFrozen = false
    self.teleportAddressLength = teleportAddressLength
    self.teleportTxHashLength = teleportTxHashLength
    self.lockVault <- WakandaToken.createEmptyVault() as! @WakandaToken.Vault
    self.unlocked = {}
    self.TeleportAdminStoragePath = /storage/teleportCustodyTeleportAdmin
    self.TeleportAdminTeleportUserPath = /public/teleportCustodyTeleportUser
    self.TeleportAdminTeleportControlPath = /private/teleportCustodyTeleportControl

    let admin <- create Administrator()
    self.account.save(<-admin, to: /storage/teleportCustodyAdmin)
  }
}