import NFTStorefront from 0xNFTStorefront

pub fun main(address: Address): Bool {
    return getAccount(address)
        .getCapability<&{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        .check()
}