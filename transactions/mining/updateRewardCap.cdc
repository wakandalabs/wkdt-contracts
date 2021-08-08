import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction(rewardCap: UFix64) {
    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        admin.updateRewardCap(rewardCap)
    }
}
