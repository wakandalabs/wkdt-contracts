import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

pub fun main(): [Address] {
    return WakandaTokenSale.getPurchasers()
}
