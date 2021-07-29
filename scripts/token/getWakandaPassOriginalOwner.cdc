import NonFungibleToken from "../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"

pub fun main(address: Address): Address? {
    let collectionRef = getAccount(address).getCapability(/public/wakandaPassCollection)
        .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
        ?? panic("Could not borrow collection public reference")

    let ids = collectionRef.getIDs()
    let wakandaPass = collectionRef.borrowWakandaPassPublic(id: ids[0])

    return wakandaPass.getOriginalOwner()
}