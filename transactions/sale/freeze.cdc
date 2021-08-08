import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

transaction() {

    // The reference to the Admin Resource
    let adminRef: &WakandaTokenSale.Admin

    prepare(account: AuthAccount) {

        // Get admin reference
        self.adminRef = account.borrow<&WakandaTokenSale.Admin>(from: WakandaTokenSale.SaleAdminStoragePath)
			?? panic("Could not borrow reference to the admin!")
    }

    execute {

        // Freeze sale
        self.adminRef.freeze()
    }
}
