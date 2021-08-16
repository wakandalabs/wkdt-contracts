pub contract WakandaProfile {
  pub let ProfilePublicPath: PublicPath
  pub let ProfileStoragePath: StoragePath

  pub resource interface WakandaProfilePublic {
    pub fun getName(): String
    pub fun getAvatar(): String
    pub fun getColor(): String
    pub fun getInfo(): String
    pub fun asReadOnly(): WakandaProfile.ReadOnly
  }

  pub resource interface WakandaProfileOwner {
    pub fun getName(): String
    pub fun getAvatar(): String
    pub fun getColor(): String
    pub fun getInfo(): String

    pub fun setName(_ name: String) {
      pre {
        name.length <= 15: "Names must be under 15 characters long."
      }
    }
    pub fun setAvatar(_ src: String)
    pub fun setColor(_ color: String)
    pub fun setInfo(_ info: String) {
      pre {
        info.length <= 280: "WakandaProfile Info can at max be 280 characters long."
      }
    }
  }

  pub resource WakandaProfileBase: WakandaProfileOwner, WakandaProfilePublic {
    access(self) var name: String
    access(self) var avatar: String
    access(self) var color: String
    access(self) var info: String

    init() {
      self.name = "Anon"
      self.avatar = ""
      self.color = "#232323"
      self.info = ""
    }

    pub fun getName(): String { return self.name }
    pub fun getAvatar(): String { return self.avatar }
    pub fun getColor(): String {return self.color }
    pub fun getInfo(): String { return self.info }

    pub fun setName(_ name: String) { self.name = name }
    pub fun setAvatar(_ src: String) { self.avatar = src }
    pub fun setColor(_ color: String) { self.color = color }
    pub fun setInfo(_ info: String) { self.info = info }

    pub fun asReadOnly(): WakandaProfile.ReadOnly {
      return WakandaProfile.ReadOnly(
        address: self.owner?.address,
        name: self.getName(),
        avatar: self.getAvatar(),
        color: self.getColor(),
        info: self.getInfo()
      )
    }
  }

  pub struct ReadOnly {
    pub let address: Address?
    pub let name: String
    pub let avatar: String
    pub let color: String
    pub let info: String

    init(address: Address?, name: String, avatar: String, color: String, info: String) {
      self.address = address
      self.name = name
      self.avatar = avatar
      self.color = color
      self.info = info
    }
  }

  pub fun new(): @WakandaProfile.WakandaProfileBase {
    return <- create WakandaProfileBase()
  }

  pub fun check(_ address: Address): Bool {
    return getAccount(address)
      .getCapability<&{WakandaProfile.WakandaProfilePublic}>(WakandaProfile.ProfilePublicPath)
      .check()
  }

  pub fun fetch(_ address: Address): &{WakandaProfile.WakandaProfilePublic} {
    return getAccount(address)
      .getCapability<&{WakandaProfile.WakandaProfilePublic}>(WakandaProfile.ProfilePublicPath)
      .borrow()!
  }

  pub fun read(_ address: Address): WakandaProfile.ReadOnly? {
    if let profile = getAccount(address).getCapability<&{WakandaProfile.WakandaProfilePublic}>(WakandaProfile.ProfilePublicPath).borrow() {
      return profile.asReadOnly()
    } else {
      return nil
    }
  }

  pub fun readMultiple(_ addresses: [Address]): {Address: WakandaProfile.ReadOnly} {
    let profiles: {Address: WakandaProfile.ReadOnly} = {}
    for address in addresses {
      let profile = WakandaProfile.read(address)
      if profile != nil {
        profiles[address] = profile!
      }
    }
    return profiles
  }


  init() {
    self.ProfilePublicPath = /public/wakandaProfile002
    self.ProfileStoragePath = /storage/wakandaProfile002

    self.account.save(<- self.new(), to: self.ProfileStoragePath)
    self.account.link<&WakandaProfileBase{WakandaProfilePublic}>(self.ProfilePublicPath, target: self.ProfileStoragePath)

    self.account
      .borrow<&WakandaProfileBase{WakandaProfileOwner}>(from: self.ProfileStoragePath)!
      .setName("wakandaUser")
  }
}