import WakandaToken from "../../../contracts/flow/token/WakandaToken.cdc"
import NonFungibleToken from "../../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaPass from "../../../contracts/flow/token/WakandaPass.cdc"

transaction(address: Address, amount: UFix64, lockupScheduleId: Int) {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
            ?? panic("Could not borrow wakanda pass collection public reference")

        let wkdtVaultRef = signer
            .borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Cannot get WKDT vault reference")

        let wkdtVault <- wkdtVaultRef.withdraw(amount: amount)

        let metadata: {String: String} = {
            "origin": "Private Sale"
        }

        minter.mintNFTWithPredefinedLockup(
            recipient: nftCollectionRef,
            metadata: metadata,
            vault: <- wkdtVault,
            lockupScheduleId: lockupScheduleId
        )
    }
}
