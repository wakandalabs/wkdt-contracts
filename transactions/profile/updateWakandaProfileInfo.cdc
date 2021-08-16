import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(info: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.WakandaProfileOwner}>(from: WakandaProfile.ProfileStoragePath)!
      .setInfo(info)
  }
}