import FungibleToken from 0xFungibleToken
import WakandaToken from 0xWakandaToken

pub fun main(address: Address): UFix64? {
  if let vault = getAccount(address).getCapability<&{FungibleToken.Balance}>(WakandaToken.TokenPublicBalancePath).borrow() {
    return vault.balance
  }
  return nil
}