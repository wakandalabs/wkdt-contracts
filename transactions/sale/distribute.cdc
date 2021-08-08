import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

transaction(address: Address) {

    // The reference to the Admin Resource
    let adminRef: &WakandaTokenSale.Admin

    prepare(account: AuthAccount) {

        // Get admin reference
        self.adminRef = account.borrow<&WakandaTokenSale.Admin>(from: WakandaTokenSale.SaleAdminStoragePath)
			?? panic("Could not borrow reference to the admin!")
    }

    execute {

        // Distribute Wakanda Token purchase
        self.adminRef.distribute(address: address)
    }
}
