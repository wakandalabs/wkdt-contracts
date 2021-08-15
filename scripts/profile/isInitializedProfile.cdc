import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

pub fun main(address: Address): Bool {
  return WakandaProfile.check(address)
}