import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main(address: Address): {UInt64: UFix64} {
    let miningRewardRef = getAccount(address).getCapability(WakandaTokenMining.MiningRewardPublicPath)
        .borrow<&{WakandaTokenMining.MiningRewardPublic}>()
        ?? panic("Could not borrow mining reward public reference")

    return miningRewardRef.getRewardsLocked()
}