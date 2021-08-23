import WakandaStorefront from 0xWakandaStorefront

// This script returns an array of all the NFTs uuids for sale through a Storefront

pub fun main(address: Address): [UInt64] {
    let storefrontRef = getAccount(address)
        .getCapability<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(
            WakandaStorefront.StorefrontPublicPath
        )
        .borrow()
        ?? panic("Could not borrow public storefront from address")

    return storefrontRef.getSaleOfferIDs()
}