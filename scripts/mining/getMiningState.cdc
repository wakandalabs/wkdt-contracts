import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): WakandaTokenMining.MiningState {
    return WakandaTokenMining.getMiningState()
}
