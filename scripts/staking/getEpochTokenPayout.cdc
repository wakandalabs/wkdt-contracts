import WakandaTokenStaking from "../../contracts/flow/staking/WakandaTokenStaking.cdc"

pub fun main(): UFix64 {
  return WakandaTokenStaking.getEpochTokenPayout()
}
