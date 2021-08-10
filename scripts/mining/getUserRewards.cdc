import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): {Address: UFix64} {
    return WakandaTokenMining.getUserRewards()
}
