import WakandaStorefront from 0xWakandaStorefront

transaction(saleOfferResourceID: UInt64) {
  let storefront: &WakandaStorefront.Storefront{WakandaStorefront.StorefrontManager}

  prepare(acct: AuthAccount) {
    self.storefront = acct.borrow<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontManager}>(from: WakandaStorefront.StorefrontStoragePath)
    ?? panic("Missing or mis-typed WakandaStorefront.Storefront")
  }

  execute {
    self.storefront.removeSaleOffer(saleOfferResourceID: saleOfferResourceID)
  }
}