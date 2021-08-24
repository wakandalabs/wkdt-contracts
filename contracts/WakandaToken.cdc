import FungibleToken from "./FungibleToken.cdc"

pub contract WakandaToken: FungibleToken {

    pub var totalSupply: UFix64

    pub let TokenAdminStoragePath: StoragePath

    pub let TokenStoragePath: StoragePath

    pub let TokenPublicBalancePath: PublicPath

    pub let TokenPublicReceiverPath: PublicPath

    pub let TokenMinterStoragePath: StoragePath

    pub event TokensInitialized(initialSupply: UFix64)

    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    pub event TokensDeposited(amount: UFix64, to: Address?)

    pub event TokensMinted(amount: UFix64)

    pub event TokensBurned(amount: UFix64)

    pub event MinterCreated(allowedAmount: UFix64)

    pub event BurnerCreated()

    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

        pub var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @WakandaToken.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            WakandaToken.totalSupply = WakandaToken.totalSupply - self.balance
        }
    }

    pub fun createEmptyVault(): @FungibleToken.Vault {
        return <-create Vault(balance: 0.0)
    }

    pub resource Administrator {
        pub fun createNewMinter(allowedAmount: UFix64): @Minter {
            emit MinterCreated(allowedAmount: allowedAmount)
            return <-create Minter(allowedAmount: allowedAmount)
        }

        pub fun createNewBurner(): @Burner {
            emit BurnerCreated()
            return <-create Burner()
        }
    }

    pub resource Minter {

        pub var allowedAmount: UFix64

        pub fun mintTokens(amount: UFix64): @WakandaToken.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
                amount <= self.allowedAmount: "Amount minted must be less than the allowed amount"
            }
            WakandaToken.totalSupply = WakandaToken.totalSupply + amount
            self.allowedAmount = self.allowedAmount - amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }

        init(allowedAmount: UFix64) {
            self.allowedAmount = allowedAmount
        }
    }

    pub resource Burner {

        pub fun burnTokens(from: @FungibleToken.Vault) {
            let vault <- from as! @WakandaToken.Vault
            let amount = vault.balance
            destroy vault
            emit TokensBurned(amount: amount)
        }
    }

    pub fun check(_ address: Address): Bool {
       let receiver: Bool = getAccount(address)
         .getCapability<&WakandaToken.Vault{FungibleToken.Receiver}>(WakandaToken.TokenPublicReceiverPath)
         .check()

       let balance: Bool = getAccount(address)
         .getCapability<&WakandaToken.Vault{FungibleToken.Balance}>(WakandaToken.TokenPublicBalancePath)
         .check()

       return receiver && balance
    }

    init() {
        // Total supply of WKDT is 10M
        // 100% is created at genesis
        self.totalSupply = 10_000_000.0

        self.TokenStoragePath = /storage/wakandaTokenVault06
        self.TokenPublicReceiverPath = /public/wakandaTokenReceiver06
        self.TokenPublicBalancePath = /public/wakandaTokenBalance06
        self.TokenMinterStoragePath = /storage/wakandaTokenMinter06
        self.TokenAdminStoragePath = /storage/wakandaTokenAdmin06

        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: self.TokenStoragePath)

        self.account.link<&WakandaToken.Vault{FungibleToken.Receiver}>(
            self.TokenPublicReceiverPath,
            target: self.TokenStoragePath
        )

        self.account.link<&WakandaToken.Vault{FungibleToken.Balance}>(
            self.TokenPublicBalancePath,
            target: self.TokenStoragePath
        )

        let admin <- create Administrator()
        self.account.save(<-admin, to: self.TokenAdminStoragePath)

        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}
