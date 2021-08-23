import WakandaStorefront from 0xWakandaStorefront
transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {
  let storefront: &WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}

  prepare(acct: AuthAccount) {
    self.storefront = getAccount(storefrontAddress)
      .getCapability<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(
      WakandaStorefront.StorefrontPublicPath
    )!
  .borrow()
    ?? panic("Cannot borrow Storefront from provided address")
  }

  execute {
    // Be kind and recycle
    self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)
  }
}