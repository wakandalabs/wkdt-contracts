import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

pub fun main(addresses: [Address]): {Address: WakandaProfile.ReadOnly} {
  return WakandaProfile.readMultiple(addresses)
}