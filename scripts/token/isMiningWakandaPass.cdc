import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"

pub fun main(address: Address): Bool {
   return getAccount(address)
       .getCapability<&{WakandaPass.MinterPublic}>(WakandaPass.MinterPublicPath)
       .check()
}




