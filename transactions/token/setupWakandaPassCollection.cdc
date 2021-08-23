import NonFungibleToken from 0xNonFungibleToken
import WakandaPass from 0xWakandaPass

transaction {
  prepare(signer: AuthAccount) {
    if !WakandaPass.check(signer.address) {
      if signer.borrow<&WakandaPass.Collection>(from: WakandaPass.CollectionStoragePath) == nil {
        let collection <- WakandaPass.createEmptyCollection() as! @WakandaPass.Collection
        signer.save(<-collection, to: WakandaPass.CollectionStoragePath)
        signer.link<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>(
            WakandaPass.CollectionPublicPath,
            target: WakandaPass.CollectionStoragePath)
      }
      if signer.borrow<&WakandaPass.NFTMinter>(from: WakandaPass.MinterStoragePath) == nil {
        let minter <- WakandaPass.createNewMinter() as! @WakandaPass.NFTMinter
        signer.save(<-minter, to: WakandaPass.MinterStoragePath)
        signer.link<&{WakandaPass.MinterPublic}>(
            WakandaPass.MinterPublicPath,
            target: WakandaPass.MinterStoragePath)
      }
    }
  }
}