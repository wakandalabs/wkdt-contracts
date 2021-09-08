import NFTStorefront from 0xNFTStorefront

// This script returns an array of all the NFTs uuids for sale through a Storefront

pub fun main(address: Address): [UInt64] {
    let storefrontRef = getAccount(address)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )
        .borrow()
        ?? panic("Could not borrow public storefront from address")

    return storefrontRef.getListingIDs()
}