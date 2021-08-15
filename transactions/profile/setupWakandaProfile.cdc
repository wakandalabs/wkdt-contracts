import WakandaProfile from "../../contracts/flow/profile/WakandaProfile.cdc"

transaction {
  let address: address
  prepare(currentUser: AuthAccount) {
    self.address = currentUser.address
    if !WakandaProfile.check(self.address) {
      currentUser.save(<- WakandaProfile.new(), to: WakandaProfile.privatePath)
      currentUser.link<&Profile.Base{WakandaProfile.Public}>(WakandaProfile.publicPath, target: WakandaProfile.privatePath)
    }
  }
  post {
    WakandaProfile.check(self.address): "Account was not initialized"
  }
}