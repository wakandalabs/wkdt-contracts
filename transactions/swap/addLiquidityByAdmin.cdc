import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import WakandaToken from "../../contracts/flow/token/WakandaToken.cdc"
import TeleportedTetherToken from "../../contracts/flow/token/TeleportedTetherToken.cdc"
import WkdtUsdtSwapPair from "../../contracts/flow/swap/WkdtUsdtSwapPair.cdc"

transaction(token1Amount: UFix64, token2Amount: UFix64) {
  prepare(signer: AuthAccount) {
    let fusdVault = signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
        ?? panic("Could not borrow a reference to Vault")
    
    let token1Vault <- fusdVault.withdraw(amount: token1Amount) as! @WakandaToken.Vault

    let tetherVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath)
        ?? panic("Could not borrow a reference to Vault")
    
    let token2Vault <- tetherVault.withdraw(amount: token2Amount) as! @TeleportedTetherToken.Vault

    let adminRef = signer.borrow<&WkdtUsdtSwapPair.Admin>(from: /storage/wkdtUsdtPairAdmin)
        ?? panic("Could not borrow a reference to Admin")

    let tokenBundle <- WkdtUsdtSwapPair.createTokenBundle(fromToken1: <- token1Vault, fromToken2: <- token2Vault);
    let liquidityTokenVault <- adminRef.addInitialLiquidity(from: <- tokenBundle)

    if signer.borrow<&WkdtUsdtSwapPair.Vault>(from: WkdtUsdtSwapPair.TokenStoragePath) == nil {
      // Create a new swap LP token Vault and put it in storage
      signer.save(<-WkdtUsdtSwapPair.createEmptyVault(), to: WkdtUsdtSwapPair.TokenStoragePath)

      // Create a public capability to the Vault that only exposes
      // the deposit function through the Receiver interface
      signer.link<&WkdtUsdtSwapPair.Vault{FungibleToken.Receiver}>(
        WkdtUsdtSwapPair.TokenPublicReceiverPath,
        target: WkdtUsdtSwapPair.TokenStoragePath
      )

      // Create a public capability to the Vault that only exposes
      // the balance field through the Balance interface
      signer.link<&WkdtUsdtSwapPair.Vault{FungibleToken.Balance}>(
        WkdtUsdtSwapPair.TokenPublicBalancePath,
        target: WkdtUsdtSwapPair.TokenStoragePath
      )
    }

    let liquidityTokenRef = signer.borrow<&WkdtUsdtSwapPair.Vault>(from: WkdtUsdtSwapPair.TokenStoragePath)
        ?? panic("Could not borrow a reference to Vault")

    liquidityTokenRef.deposit(from: <- liquidityTokenVault)
  }
}
 