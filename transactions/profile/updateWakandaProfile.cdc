import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction(name: String, avatar: String, color: String, info: String) {
  prepare(currentUser: AuthAccount) {
    currentUser
      .borrow<&{WakandaProfile.Owner}>(from: WakandaProfile.privatePath)!
      .setName(name)
      .setAvatar(avatar)
      .setColor(color)
      .setInfo(info)
  }
}