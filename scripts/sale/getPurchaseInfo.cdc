import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

pub fun main(address: Address): WakandaTokenSale.PurchaseInfo? {
    return WakandaTokenSale.getPurchase(address: address)
}
