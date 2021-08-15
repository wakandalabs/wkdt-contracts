import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(name: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.Owner}>(from: WakandaProfile.privatePath)!
      .setName(name)
  }
}