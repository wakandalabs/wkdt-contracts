import FungibleToken from 0xFungibleToken
import WakandaToken from 0xWakandaToken

transaction {
  prepare(signer: AuthAccount) {
    if !WakandaToken.check(signer.address) {
      if(signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath) == nil) {
        signer.save(<-WakandaToken.createEmptyVault(), to: WakandaToken.TokenStoragePath)
        signer.link<&WakandaToken.Vault{FungibleToken.Receiver}>(
          WakandaToken.TokenPublicReceiverPath,
          target: WakandaToken.TokenStoragePath
        )
        signer.link<&WakandaToken.Vault{FungibleToken.Balance}>(
          WakandaToken.TokenPublicBalancePath,
          target: WakandaToken.TokenStoragePath
        )
      }
    }
  }
}