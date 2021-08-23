import FungibleToken from 0xFungibleToken
import WakandaToken from 0xWakandaToken
import WakandaPass from 0xWakandaPass

transaction() {
    // The private reference to user's WakandaToken vault
    let vaultRef: &WakandaToken.Vault

    // The private reference to user's WakandaPass
    let wakandaPassRef: &WakandaPass.NFT

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored vault
        self.vaultRef = signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Get a reference to the signer's WakandaPass
        let wakandaPassCollectionRef = signer.borrow<&WakandaPass.Collection>(from: /storage/wakandaPassCollection)
			?? panic("Could not borrow reference to the owner's WakandaPass collection!")

        let ids = wakandaPassCollectionRef.getIDs()

        // Get a reference to the
        self.wakandaPassRef = wakandaPassCollectionRef.borrowWakandaPassPrivate(id: ids[0])
    }

    execute {
        let vault <- self.wakandaPassRef.withdrawAllUnlockedTokens()

        self.vaultRef.deposit(from: <- vault)
    }
}
