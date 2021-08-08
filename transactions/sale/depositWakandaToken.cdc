import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import WakandaToken from "../../contracts/flow/token/WakandaToken.cdc"
import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

transaction(amount: UFix64) {

    // The reference to the Admin Resource
    let adminRef: &WakandaTokenSale.Admin

    // The tUSDT Vault resource that holds the tokens that are being transferred
    let sentVault:  @FungibleToken.Vault

    prepare(account: AuthAccount) {

        // Get admin reference
        self.adminRef = account.borrow<&WakandaTokenSale.Admin>(from: WakandaTokenSale.SaleAdminStoragePath)
			?? panic("Could not borrow reference to the admin!")

        // Get a reference to the signer's stored vault
        let vaultRef = account.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {

        // Deposit Wakanda Token
        self.adminRef.depositWkdt(from: <-self.sentVault)
    }
}
