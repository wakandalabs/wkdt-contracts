import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(name: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.WakandaProfileOwner}>(from: WakandaProfile.ProfileStoragePath)!
      .setName(name)
  }
}