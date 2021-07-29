import Vibranium from "../../../contracts/flow/token/Vibranium.cdc"
import NonFungibleToken from "../../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaPass from "../../../contracts/flow/token/WakandaPass.cdc"

transaction(address: Address, amount: UFix64, unlockTime: UFix64) {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
            ?? panic("Could not borrow wakanda pass collection public reference")

        let vibraVaultRef = signer
            .borrow<&Vibranium.Vault>(from: Vibranium.TokenStoragePath)
            ?? panic("Cannot get VIBRA vault reference")

        let vibraVault <- vibraVaultRef.withdraw(amount: amount)

        let metadata: {String: String} = {
            "origin": "Private Sale"
        }

        let lockupSchedule: {UFix64: UFix64} = {
            0.0                : 1.0,
            unlockTime - 300.0 : 1.0,
            unlockTime - 240.0 : 0.8,
            unlockTime - 180.0 : 0.6,
            unlockTime - 120.0 : 0.4,
            unlockTime - 60.0  : 0.2,
            unlockTime         : 0.0
        }

        minter.mintNFTWithCustomLockup(
            recipient: nftCollectionRef,
            metadata: metadata,
            vault: <- vibraVault,
            lockupSchedule: lockupSchedule
        )
    }
}