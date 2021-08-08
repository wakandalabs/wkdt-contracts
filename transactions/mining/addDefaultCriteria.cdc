import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        let tx = WakandaTokenMining.Criteria(reward: 1.0, divisor: 2.0, capTimes: 5)
        let referral = WakandaTokenMining.Criteria(reward: 5.0, divisor: 1.0, capTimes: 6)
        let assetInCirculation = WakandaTokenMining.Criteria(reward: 1.0, divisor: 100.0, capTimes: 10)

        admin.updateCriteria(name: "tx", criteria: tx)
        admin.updateCriteria(name: "referral", criteria: referral)
        admin.updateCriteria(name: "assetInCirculation", criteria: assetInCirculation)
    }
}
