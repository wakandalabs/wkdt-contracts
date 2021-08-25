import FungibleToken from 0xFungibleToken
import WakandaToken from 0xWakandaToken

transaction(amount: UFix64) {

    let vault: @FungibleToken.Vault

    let admin: &WakandaToken.Administrator

    prepare(signer: AuthAccount) {

        self.vault <- signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)!
            .withdraw(amount: amount)

        self.admin = signer.borrow<&WakandaToken.Administrator>(from: WakandaToken.TokenAdminStoragePath)
            ?? panic("Could not borrow a reference to the admin resource")
    }

    execute {
        let burner <- self.admin.createNewBurner()
        burner.burnTokens(from: <-self.vault)
        destroy burner
    }
}
