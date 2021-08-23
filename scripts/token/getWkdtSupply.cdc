import WakandaToken from "../../contracts/token/WakandaToken.cdc"

pub fun main(): UFix64 {

    let supply = WakandaToken.totalSupply

    log(supply)

    return supply
}
