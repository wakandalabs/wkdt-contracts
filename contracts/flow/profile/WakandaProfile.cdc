pub contract WakandaProfile {
  pub let ProfilePublicPath: PublicPath
  pub let ProfileStoragePath: StoragePath

  pub resource interface WakandaProfilePublic {
    pub fun getName(): String
    pub fun getAvatar(): String
    pub fun getColor(): String
    pub fun getBio(): String
    pub fun getWebsite(): String
    pub fun getEmail(): String
    pub fun asReadOnly(): WakandaProfile.ReadOnly
  }

  pub resource interface WakandaProfileOwner {
    pub fun getName(): String
    pub fun getAvatar(): String
    pub fun getColor(): String
    pub fun getBio(): String
    pub fun getWebsite(): String
    pub fun getEmail(): String

    pub fun setName(_ name: String) {
      pre {
        name.length <= 15: "Names must be under 15 characters long."
      }
    }
    pub fun setAvatar(_ src: String)
    pub fun setColor(_ color: String)
    pub fun setBio(_ bio: String) {
      pre {
        bio.length <= 280: "Bio can at max be 280 characters long."
      }
    }
    pub fun setWebsite(_ website: String) {
      pre {
        website.length <= 40: "Website can at max be 40 characters long."
      }
    }
    pub fun setEmail(_ email: String) {
      pre {
        email.length <= 40: "Email can at max be 40 characters long."
      }
    }
  }

  pub resource WakandaProfileBase: WakandaProfileOwner, WakandaProfilePublic {
    access(self) var name: String
    access(self) var avatar: String
    access(self) var color: String
    access(self) var bio: String
    access(self) var website: String
    access(self) var email: String

    init() {
      self.name = "Wak"
      self.avatar = ""
      self.color = "#232323"
      self.bio = "Wakanda User"
      self.website = ""
      self.email = ""
    }

    pub fun getName(): String { return self.name }
    pub fun getAvatar(): String { return self.avatar }
    pub fun getColor(): String {return self.color }
    pub fun getBio(): String { return self.bio }
    pub fun getWebsite(): String { return self.website }
    pub fun getEmail(): String { return self.email }

    pub fun setName(_ name: String) { self.name = name }
    pub fun setAvatar(_ src: String) { self.avatar = src }
    pub fun setColor(_ color: String) { self.color = color }
    pub fun setBio(_ bio: String) { self.bio = bio }
    pub fun setWebsite(_ website: String) { self.website = website }
    pub fun setEmail(_ email: String) { self.email = email }

    pub fun asReadOnly(): WakandaProfile.ReadOnly {
      return WakandaProfile.ReadOnly(
        address: self.owner?.address,
        name: self.getName(),
        avatar: self.getAvatar(),
        color: self.getColor(),
        bio: self.getBio(),
        website: self.getWebsite(),
        email: self.getEmail()
      )
    }
  }

  pub struct ReadOnly {
    pub let address: Address?
    pub let name: String
    pub let avatar: String
    pub let color: String
    pub let bio: String
    pub let website: String
    pub let email: String

    init(address: Address?, name: String, avatar: String, color: String, bio: String, website: String, email: String) {
      self.address = address
      self.name = name
      self.avatar = avatar
      self.color = color
      self.bio = bio
      self.website = website
      self.email = email
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
    self.ProfilePublicPath = /public/wakandaProfile05
    self.ProfileStoragePath = /storage/wakandaProfile05

    self.account.save(<- self.new(), to: self.ProfileStoragePath)
    self.account.link<&WakandaProfileBase{WakandaProfilePublic}>(self.ProfilePublicPath, target: self.ProfileStoragePath)
  }
}