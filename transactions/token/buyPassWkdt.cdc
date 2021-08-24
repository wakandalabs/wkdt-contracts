import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken
import WakandaToken from 0xWakandaToken
import WakandaPass from 0xWakandaPass
import WakandaStorefront from 0xWakandaStorefront

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {

    let paymentVault: @FungibleToken.Vault
    let wakandaPassCollection: &WakandaPass.Collection{NonFungibleToken.Receiver}
    let storefront: &WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}
    let saleOffer: &WakandaStorefront.SaleOffer{WakandaStorefront.SaleOfferPublic}

    prepare(account: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&WakandaStorefront.Storefront{WakandaStorefront.StorefrontPublic}>(
                WakandaStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Cannot borrow Storefront from provided address")

        self.saleOffer = self.storefront.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID)
            ?? panic("No offer with that ID in Storefront")

        let price = self.saleOffer.getDetails().salePrice

        let mainWakandaTokenVault = account.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Cannot borrow WakandaToken vault from account storage")

        self.paymentVault <- mainWakandaTokenVault.withdraw(amount: price)

        self.wakandaPassCollection = account.borrow<&WakandaPass.Collection{NonFungibleToken.Receiver}>(
            from: WakandaPass.CollectionStoragePath
        ) ?? panic("Cannot borrow WakandaPass collection receiver from account")
    }

    execute {
        let item <- self.saleOffer.accept(
            payment: <-self.paymentVault
        )

        self.wakandaPassCollection.deposit(token: <-item)

        self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)
    }
}