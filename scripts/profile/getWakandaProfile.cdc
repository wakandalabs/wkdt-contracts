import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

pub fun main(address: Address): WakandaProfile.ReadOnly? {
  return WakandaProfile.read(address)
}