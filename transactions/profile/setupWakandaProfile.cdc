import WakandaProfile from 0xWakandaProfile

transaction {
  prepare(signer: AuthAccount) {
    if !WakandaProfile.check(signer.address) {
      if signer.borrow<&WakandaProfile.WakandaProfileBase>(from: WakandaProfile.ProfileStoragePath) ==nil {
        signer.save(<- WakandaProfile.new(), to: WakandaProfile.ProfileStoragePath)
        signer.link<&WakandaProfile.WakandaProfileBase{WakandaProfile.WakandaProfilePublic}>(WakandaProfile.ProfilePublicPath, target: WakandaProfile.ProfileStoragePath)
      }
    }
  }
}