import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): UInt64 {
    return WakandaTokenMining.getCurrentRound()
}
