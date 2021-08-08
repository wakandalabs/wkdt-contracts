import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&WakandaTokenMining.MiningReward>(from: WakandaTokenMining.MiningRewardStoragePath) == nil {

            let miningReward <- WakandaTokenMining.createEmptyMiningReward()

            signer.save(<-miningReward, to: WakandaTokenMining.MiningRewardStoragePath)

            signer.link<&{WakandaTokenMining.MiningRewardPublic}>(
                WakandaTokenMining.MiningRewardPublicPath,
                target: WakandaTokenMining.MiningRewardStoragePath)
        }
    }
}