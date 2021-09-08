import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken
import WakandaToken from 0xWakandaToken
import WakandaPass from 0xWakandaPass
import NFTStorefront from 0xNFTStorefront

transaction(salePassID: UInt64, salePassPrice: UFix64) {

    let wkdtReceiver: Capability<&WakandaToken.Vault{FungibleToken.Receiver}>
    let wakandaPassProvider: Capability<&WakandaPass.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(account: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let wakandaPassCollectionProviderPrivatePath = /private/wakandaPassCollectionProvider

        self.wkdtReceiver = account.getCapability<&WakandaToken.Vault{FungibleToken.Receiver}>(WakandaToken.TokenPublicReceiverPath)!

        assert(self.wkdtReceiver.borrow() != nil, message: "Missing or mis-typed WakandaToken receiver")

        if !account.getCapability<&WakandaPass.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(wakandaPassCollectionProviderPrivatePath)!.check() {
            account.link<&WakandaPass.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(wakandaPassCollectionProviderPrivatePath, target: WakandaPass.CollectionStoragePath)
        }

        self.wakandaPassProvider = account.getCapability<&WakandaPass.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(wakandaPassCollectionProviderPrivatePath)!
        assert(self.wakandaPassProvider.borrow() != nil, message: "Missing or mis-typed WakandaPass.Collection provider")

        self.storefront = account.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.wkdtReceiver,
            amount: salePassPrice
        )
        self.storefront.createListing(
            nftProviderCapability: self.wakandaPassProvider,
            nftType: Type<@WakandaPass.NFT>(),
            nftID: salePassID,
            salePaymentVaultType: Type<@WakandaToken.Vault>(),
            saleCuts: [saleCut]
        )
    }
}