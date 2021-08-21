import WakandaStorefront from 0xWakandaStorefront

transaction {
    prepare(acct: AuthAccount) {

        // If the account doesn't already have a Storefront
        if acct.borrow<&WakandaStorefront.Storefront>(from: WakandaStorefront.StorefrontStoragePath) == nil {

            // Create a new empty .Storefront
            let storefront <- WakandaStorefront.createStorefront() as @WakandaStorefront.Storefront

            // save it to the account
            acct.save(<-storefront, to: WakandaStorefront.StorefrontStoragePath)

            // create a public capability for the .Storefront
            acct.link<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(WakandaStorefront.StorefrontPublicPath, target: WakandaStorefront.StorefrontStoragePath)
        }
    }
}