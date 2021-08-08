import FungibleToken from "../../../contracts/flow/token/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaToken from "../../../contracts/flow/token/WakandaToken.cdc"
import WakandaPass from "../../../contracts/flow/token/WakandaPass.cdc"

transaction(address: Address, amount: UFix64) {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
            ?? panic("Could not borrow wakanda pass collection public reference")

        let vibraVaultRef = signer
            .borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Cannot get WKDT vault reference")

        let vibraVault <- vibraVaultRef.withdraw(amount: amount)

        let metadata: {String: String} = {
            "origin": "Wakanda Team"
        }

        minter.mintNFTWithPredefinedLockup(
            recipient: nftCollectionRef,
            metadata: metadata,
            vault: <- vibraVault,
            lockupScheduleId: 2
        )

        // Get a reference to the signer's stored vault
        let flowVaultRef = signer.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Get the recipient's public account object
        let recipient = getAccount(address)

        // Get a reference to the recipient's FLOW Receiver
        let receiverRef = recipient.getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiverRef.deposit(from: <-flowVaultRef.withdraw(amount: 0.0001))
    }
}
