import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(): {String: WakandaTokenMining.Criteria} {
    return WakandaTokenMining.getCriterias()
}
