import WakandaPass from 0xWakandaPass

pub fun main(address: Address, id: UInt64): WakandaPass.ReadOnly? {
    return WakandaPass.read(address: address, id: id)
}