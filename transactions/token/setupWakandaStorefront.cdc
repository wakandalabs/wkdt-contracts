import WakandaStorefront from 0xWakandaStorefront

transaction {
    prepare(acct: AuthAccount) {

        if acct.borrow<&WakandaStorefront.Storefront>(from: WakandaStorefront.StorefrontStoragePath) == nil {
            let storefront <- WakandaStorefront.createStorefront() as @WakandaStorefront.Storefront
            acct.save(<-storefront, to: WakandaStorefront.StorefrontStoragePath)
            acct.link<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(WakandaStorefront.StorefrontPublicPath, target: WakandaStorefront.StorefrontStoragePath)
        }
    }
}