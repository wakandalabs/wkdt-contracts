import NonFungibleToken from 0xNonFungibleToken
import WakandaPass from 0xWakandaPass

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