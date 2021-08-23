import WakandaStorefront from 0xWakandaStorefront

pub fun main(address: Address, saleOfferResourceID: UInt64): WakandaStorefront.SaleOfferDetails {
    let storefrontRef = getAccount(address)
        .getCapability<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(
            WakandaStorefront.StorefrontPublicPath
        )
        .borrow()
        ?? panic("Could not borrow public storefront from address")

    let saleOffer = storefrontRef.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID)
        ?? panic("No item with that ID")

    return saleOffer.getDetails()
}