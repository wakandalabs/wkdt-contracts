import WakandaToken from 0xWakandaToken
import NonFungibleToken from 0xNonFungibleToken
import WakandaPass from 0xWakandaPass

transaction(receiver: Address, metadata: {String: String}, lockupAmount: UFix64, lockupSchedule: {UFix64: UFix64}) {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = getAccount(receiver).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
            ?? panic("Could not borrow WakandaPass collection public reference")

        let wkdtVaultRef = signer
            .borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Cannot get WKDT vault reference")

        let wkdtVault <- wkdtVaultRef.withdraw(amount: lockupAmount)

        minter.mintNFTWithCustomLockup(
            recipient: nftCollectionRef,
            metadata: metadata,
            vault: <- wkdtVault,
            lockupSchedule: lockupSchedule
        )
    }
}