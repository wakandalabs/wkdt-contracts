import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(color: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.WakandaProfileOwner}>(from: WakandaProfile.ProfileStoragePath)!
      .setColor(color)
  }
}