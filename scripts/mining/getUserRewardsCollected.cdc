import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): {Address: UInt64} {
    return WakandaTokenMining.getUserRewardsCollected()
}
