import NonFungibleToken from 0xNonFungibleToken
import WakandaPass from 0xWakandaPass

pub fun main(address: Address): [UInt64] {
    return WakandaPass.fetch(address).getIDs()
}