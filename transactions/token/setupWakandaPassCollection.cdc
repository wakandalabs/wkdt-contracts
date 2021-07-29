import NonFungibleToken from "../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&WakandaPass.Collection>(from: WakandaPass.CollectionStoragePath) == nil {

            let collection <- WakandaPass.createEmptyCollection() as! @WakandaPass.Collection

            signer.save(<-collection, to: WakandaPass.CollectionStoragePath)

            signer.link<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>(
                WakandaPass.CollectionPublicPath,
                target: WakandaPass.CollectionStoragePath)
        }
    }
}