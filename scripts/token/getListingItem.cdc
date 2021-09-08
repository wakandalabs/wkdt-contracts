import NonFungibleToken from 0xNonFungibleToken
import NFTStorefront from 0xNFTStorefront
import WakandaPass from 0xWakandaPass

pub struct SaleItem {
    pub let item: WakandaPass.ReadOnly?
    pub let price: UFix64

    init(item: WakandaPass.ReadOnly?, price: UFix64) {
        self.item = item
        self.price = price
    }
}

pub fun main(address: Address, listingResourceID: UInt64): SaleItem? {
    if let storefrontRef = getAccount(address)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath).borrow() {

        if let listing = storefrontRef.borrowListing(listingResourceID: listingResourceID) {
            let details = listing.getDetails()
            let itemPrice = details.salePrice

            let item = WakandaPass.read(address: address, id: details.nftID)

            return SaleItem(item: item, price: itemPrice)
        }
    }
    return nil
}