import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction {
  let address: address
  prepare(currentUser: AuthAccount) {
    self.address = currentUser.address
    if !WakandaProfile.check(self.address) {
      currentUser.save(<- WakandaProfile.new(), to: WakandaProfile.ProfileStoragePath)
      currentUser.link<&WakandaProfile.Base{WakandaProfile.WakandaProfilePublic}>(WakandaProfile.ProfilePublicPath, target: WakandaProfile.ProfileStoragePath)
    }
  }
  post {
    WakandaProfile.check(self.address): "Account was not initialized"
  }
}