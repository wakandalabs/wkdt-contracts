import FungibleToken from 0xFungibleToken
import WakandaToken from 0xWakandaToken
import WakandaPass from 0xWakandaPass

transaction(amount: UFix64) {

    // The Vault resource that holds the tokens that are being transferred
    let sentVault: @FungibleToken.Vault

    // The private reference to user's WakandaPass
    let wakandaPassRef: &WakandaPass.NFT

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored vault
        let vaultRef = signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount)

        // Get a reference to the signer's WakandaPass
        let wakandaPassCollectionRef = signer.borrow<&WakandaPass.Collection>(from: /storage/wakandaPassCollection)
			?? panic("Could not borrow reference to the owner's WakandaPass collection!")

        let ids = wakandaPassCollectionRef.getIDs()

        // Get a reference to the
        self.wakandaPassRef = wakandaPassCollectionRef.borrowWakandaPassPrivate(id: ids[0])
    }

    execute {
        // Deposit WKDT balance into WakandaPass first
        self.wakandaPassRef.deposit(from: <- self.sentVault)
    }
}