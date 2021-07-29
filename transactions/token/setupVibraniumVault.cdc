import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import Vibranium from "../../contracts/flow/token/Vibranium.cdc"

transaction {

    prepare(signer: AuthAccount) {

        // If the account is already set up that's not a problem, but we don't want to replace it
        if(signer.borrow<&Vibranium.Vault>(from: Vibranium.TokenStoragePath) != nil) {
            return
        }

        // Create a new Vibranium Vault and put it in storage
        signer.save(<-Vibranium.createEmptyVault(), to: Vibranium.TokenStoragePath)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&Vibranium.Vault{FungibleToken.Receiver}>(
            Vibranium.TokenPublicReceiverPath,
            target: Vibranium.TokenStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&Vibranium.Vault{FungibleToken.Balance}>(
            Vibranium.TokenPublicBalancePath,
            target: Vibranium.TokenStoragePath
        )
    }
}