import FungibleToken from "../../contracts/FungibleToken.cdc"
import WakandaToken from "../../contracts/WakandaToken.cdc"

transaction {

    prepare(signer: AuthAccount) {

        // If the account is already set up that's not a problem, but we don't want to replace it
        if(signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath) != nil) {
            return
        }

        // Create a new WakandaToken Vault and put it in storage
        signer.save(<-WakandaToken.createEmptyVault(), to: WakandaToken.TokenStoragePath)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&WakandaToken.Vault{FungibleToken.Receiver}>(
            WakandaToken.TokenPublicReceiverPath,
            target: WakandaToken.TokenStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&WakandaToken.Vault{FungibleToken.Balance}>(
            WakandaToken.TokenPublicBalancePath,
            target: WakandaToken.TokenStoragePath
        )
    }
}