import WakandaProfile from 0xWakandaProfile

pub fun main(addresses: [Address]): {Address: WakandaProfile.ReadOnly} {
  return WakandaProfile.readMultiple(addresses)
}