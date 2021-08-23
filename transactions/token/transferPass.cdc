import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import WakandaPass from "../../contracts/WakandaPass.cdc"

transaction(recipient: Address, withdrawID: UInt64) {
    prepare(signer: AuthAccount) {

        let recipient = getAccount(recipient)

        let collectionRef = signer.borrow<&WakandaPass.Collection>(from: WakandaPass.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        let depositRef = recipient.getCapability(WakandaPass.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        depositRef.deposit(token: <-nft)
    }
}

