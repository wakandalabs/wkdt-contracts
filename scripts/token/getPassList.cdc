import NonFungibleToken from 0xNonFungibleToken
import WakandaPass from 0xWakandaPass

pub fun main(address: Address): [WakandaPass.ReadOnly] {
    return WakandaPass.readMultiple(address)
}