import NonFungibleToken from "../../contracts/flow/token/NonFungibleToken.cdc"
import TeleportedTetherToken from "../../contracts/flow/token/TeleportedTetherToken.cdc"
import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"
import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

transaction(amount: UFix64) {

    // The tUSDT Vault resource that holds the tokens that are being transferred
    let sentVault:  @TeleportedTetherToken.Vault

    // The address of the Wakanda Token buyer
    let buyerAddress: Address

    prepare(account: AuthAccount) {

        // Get a reference to the signer's stored vault
        let vaultRef = account.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount) as! @TeleportedTetherToken.Vault

        // Record the buyer address
        self.buyerAddress = account.address

        // If user does not have WakandaPass collection yet, create one to receive
        if account.borrow<&WakandaPass.Collection>(from: WakandaPass.CollectionStoragePath) == nil {

            let collection <- WakandaPass.createEmptyCollection() as! @WakandaPass.Collection

            account.save(<-collection, to: WakandaPass.CollectionStoragePath)

            account.link<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>(
                WakandaPass.CollectionPublicPath,
                target: WakandaPass.CollectionStoragePath)
        }
    }

    execute {

        // Enroll in Wakanda Token community sale
        WakandaTokenSale.purchase(from: <-self.sentVault, address: self.buyerAddress)
    }
}
