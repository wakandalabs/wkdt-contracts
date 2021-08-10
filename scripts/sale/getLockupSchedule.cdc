import WakandaTokenSale from "../../contracts/flow/sale/WakandaTokenSale.cdc"

pub fun main(): {UFix64: UFix64} {
    return WakandaTokenSale.getLockupSchedule()
}
