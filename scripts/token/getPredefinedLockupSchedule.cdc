import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"

pub fun main(id: Int): {UFix64: UFix64} {
    return WakandaPass.getPredefinedLockupSchedule(id: id)
}
