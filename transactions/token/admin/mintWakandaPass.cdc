import NonFungibleToken from "../../../contracts/flow/token/NonFungibleToken.cdc"
import WakandaPass from "../../../contracts/flow/token/WakandaPass.cdc"

transaction(address: Address, metadata: {String: String}) {

    prepare(signer: AuthAccount) {
        let minter = signer
            .borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath)
            ?? panic("Signer is not the admin")

        let nftCollectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow WakandaPass collection public reference")

        minter.mintNFT(recipient: nftCollectionRef, metadata: metadata)
    }
}