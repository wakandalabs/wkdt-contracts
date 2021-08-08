import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction(name: String, reward: UFix64, divisor: UFix64, capTimes: UInt64) {

    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        let criteria = WakandaTokenMining.Criteria(reward: reward, divisor: divisor, capTimes: capTimes)

        admin.updateCriteria(name: name, criteria: criteria)
    }
}
