import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import WakandaToken from "../../contracts/flow/token/WakandaToken.cdc"
import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"

transaction(amount: UFix64) {

    // The private reference to user's WakandaPass
    let wakandaPassRef: &WakandaPass.NFT

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's WakandaPass
        let wakandaPassCollectionRef = signer.borrow<&WakandaPass.Collection>(from: /storage/wakandaPassCollection)
			?? panic("Could not borrow reference to the owner's WakandaPass collection!")

        let ids = wakandaPassCollectionRef.getIDs()

        // Get a reference to the 
        self.wakandaPassRef = wakandaPassCollectionRef.borrowWakandaPassPrivate(id: ids[0])
    }

    execute {
        // Perform staking action
        self.wakandaPassRef.stakeNewTokens(amount: amount)
    }
}