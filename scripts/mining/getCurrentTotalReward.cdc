import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): UFix64 {
    return WakandaTokenMining.getCurrentTotalReward()
}
