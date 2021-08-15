import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(color: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.Owner}>(from: WakandaProfile.privatePath)!
      .setColor(color)
  }
}