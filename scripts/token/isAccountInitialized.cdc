import WakandaPass from "../../contracts/flow/token/WakandaPass.cdc"
import WakandaToken from "../../contracts/flow/token/WakandaToken.cdc"
import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

pub fun main(address: Address): {String: Bool} {
    let ret: {String: Bool} = {}
    ret["WakandaProfile"] = WakandaProfile.check(address)
    ret["WakandaToken"] = WakandaToken.check(address)
    ret["WakandaPass"] = WakandaPass.check(address)
    return ret
}