import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken
import WakandaToken from 0xWakandaToken
import WakandaPass from 0xWakandaPass
import NFTStorefront from 0xNFTStorefront

transaction(listingResourceID: UInt64, storefrontAddress: Address) {

    let paymentVault: @FungibleToken.Vault
    let wakandaPassCollection: &WakandaPass.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(account: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Cannot borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No offer with that ID in Storefront")

        let price = self.listing.getDetails().salePrice

        let mainWakandaTokenVault = account.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Cannot borrow WakandaToken vault from account storage")

        self.paymentVault <- mainWakandaTokenVault.withdraw(amount: price)

        self.wakandaPassCollection = account.borrow<&WakandaPass.Collection{NonFungibleToken.Receiver}>(
            from: WakandaPass.CollectionStoragePath
        ) ?? panic("Cannot borrow WakandaPass collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.wakandaPassCollection.deposit(token: <-item)

        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}