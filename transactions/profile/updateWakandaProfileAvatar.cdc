import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(avatar: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.WakandaProfileOwner}>(from: WakandaProfile.ProfileStoragePath)!
      .setAvatar(avatar)
  }
}