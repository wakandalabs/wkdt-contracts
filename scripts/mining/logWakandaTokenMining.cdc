import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

pub fun main() {
    log({"miningState": WakandaTokenMining.getMiningState()})
    log({"currentRound": WakandaTokenMining.getCurrentRound()})
    log({"currentTotalReward": WakandaTokenMining.getCurrentTotalReward()})
    log({"rewardCap": WakandaTokenMining.getRewardCap()})
    log({"capMultiplier": WakandaTokenMining.getCapMultiplier()})
    log({"criterias": WakandaTokenMining.getCriterias()})
    log({"rewardLockPeriod": WakandaTokenMining.getRewardLockPeriod()})
    log({"rewardLockRatio": WakandaTokenMining.getRewardLockRatio()})
    log({"userRewardsCollected": WakandaTokenMining.getUserRewardsCollected()})
    log({"userRewards": WakandaTokenMining.getUserRewards()})
    log({"rewardsDistributed": WakandaTokenMining.getRewardsDistributed()})
}
