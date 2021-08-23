import WakandaProfile from 0xWakandaProfile

pub fun main(address: Address): WakandaProfile.ReadOnly? {
  return WakandaProfile.read(address)
}