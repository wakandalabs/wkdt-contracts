import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import WakandaToken from "./WakandaToken.cdc"

pub contract WakandaPass: NonFungibleToken {

    pub var totalSupply: UInt64
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath
    pub let MinterPublicPath: PublicPath

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event LockupScheduleDefined(id: Int, lockupSchedule: {UFix64: UFix64})
    pub event LockupScheduleUpdated(id: Int, lockupSchedule: {UFix64: UFix64})

    pub resource interface WakandaPassPrivate {
        pub fun withdrawAllUnlockedTokens(): @FungibleToken.Vault
    }

    pub resource interface WakandaPassPublic {
        pub fun getOriginalOwner(): Address?
        pub fun getMetadata(): {String: String}
        pub fun getLockupSchedule(): {UFix64: UFix64}
        pub fun getLockupAmountAtTimestamp(timestamp: UFix64): UFix64
        pub fun getLockupAmount(): UFix64
        pub fun getIdleBalance(): UFix64
        pub fun asReadOnly(): WakandaPass.ReadOnly
    }

    pub resource NFT:
        NonFungibleToken.INFT,
        FungibleToken.Provider,
        FungibleToken.Receiver,
        WakandaPassPrivate,
        WakandaPassPublic
    {
        access(self) let vault: @WakandaToken.Vault
        pub let id: UInt64
        pub let originalOwner: Address?
        access(self) var metadata: {String: String}
        pub let lockupAmount: UFix64
        access(self) let lockupSchedule: {UFix64: UFix64}?
        init(
            initID: UInt64,
            originalOwner: Address?,
            metadata: {String: String},
            vault: @FungibleToken.Vault,
            lockupSchedule: {UFix64: UFix64}?
        ) {
            self.id = initID
            self.originalOwner = originalOwner
            self.metadata = metadata
            self.vault <- vault as! @WakandaToken.Vault

            self.lockupAmount = self.vault.balance
            self.lockupSchedule = lockupSchedule
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            post {
                self.getIdleBalance() >= self.getLockupAmount(): "Cannot withdraw locked-up WKDTs"
            }
            return <- self.vault.withdraw(amount: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            self.vault.deposit(from: <- from)
        }

        pub fun getOriginalOwner(): Address? {
            return self.originalOwner
        }

        pub fun getMetadata(): {String: String} {
            return self.metadata
        }

        pub fun getLockupSchedule(): {UFix64: UFix64} {
            return self.lockupSchedule ?? {0.0: 0.0}
        }

        pub fun getLockupAmountAtTimestamp(timestamp: UFix64): UFix64 {
            if (self.lockupAmount == 0.0) {
                return 0.0
            }

            let lockupSchedule = self.getLockupSchedule()

            let keys = lockupSchedule.keys
            var closestTimestamp = 0.0
            var lockupPercentage = 0.0

            for key in keys {
                if timestamp >= key && key >= closestTimestamp {
                    lockupPercentage = lockupSchedule[key]!
                    closestTimestamp = key
                }
            }

            return lockupPercentage * self.lockupAmount
        }

        pub fun getLockupAmount(): UFix64 {
            return self.getLockupAmountAtTimestamp(timestamp: getCurrentBlock().timestamp)
        }

        pub fun getIdleBalance(): UFix64 {
            return self.vault.balance
        }

        pub fun asReadOnly(): WakandaPass.ReadOnly {
             return WakandaPass.ReadOnly(
                id: self.id,
                owner: self.owner?.address,
                originalOwner: self.getOriginalOwner(),
                metadata: self.getMetadata(),
                lockupSchedule: self.getLockupSchedule(),
                lockupAmount: self.getLockupAmount(),
                idleBalance: self.getIdleBalance()
             )
        }

        pub fun withdrawAllUnlockedTokens(): @FungibleToken.Vault {
            let unlockedAmount = self.getIdleBalance() - self.getLockupAmount()
            let withdrawAmount = unlockedAmount < self.getIdleBalance() ? unlockedAmount : self.getIdleBalance()
            return <- self.vault.withdraw(amount: withdrawAmount)
        }

        destroy() {
            destroy self.vault
        }
    }

    pub struct ReadOnly {
        pub let id: UInt64
        pub let owner: Address?
        pub let originalOwner: Address?
        pub let metadata: {String: String}
        pub let lockupSchedule: {UFix64: UFix64}
        pub let lockupAmount: UFix64
        pub let idleBalance: UFix64

        init(id: UInt64, owner: Address?, originalOwner: Address?, metadata: {String: String}, lockupSchedule: {UFix64: UFix64}, lockupAmount: UFix64, idleBalance: UFix64) {
            self.id = id
            self.owner = owner
            self.originalOwner = originalOwner
            self.metadata = metadata
            self.lockupSchedule = lockupSchedule
            self.lockupAmount = lockupAmount
            self.idleBalance = idleBalance
        }
    }

    pub resource interface CollectionPublic {
        pub fun borrowWakandaPassPublic(id: UInt64): &WakandaPass.NFT{WakandaPass.WakandaPassPublic, FungibleToken.Receiver, NonFungibleToken.INFT}
    }

    pub resource interface CollectionPrivate {
        pub fun borrowWakandaPassPrivate(id: UInt64): &WakandaPass.NFT
    }

    pub resource Collection:
        NonFungibleToken.Provider,
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        CollectionPublic,
        CollectionPrivate
    {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @WakandaPass.NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowWakandaPassPublic(id: UInt64): &WakandaPass.NFT{WakandaPass.WakandaPassPublic, FungibleToken.Receiver, NonFungibleToken.INFT} {
            let wakandaPassRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let intermediateRef = wakandaPassRef as! auth &WakandaPass.NFT

            return intermediateRef as &WakandaPass.NFT{WakandaPass.WakandaPassPublic, FungibleToken.Receiver, NonFungibleToken.INFT}
        }

        pub fun borrowWakandaPassPrivate(id: UInt64): &WakandaPass.NFT {
            let wakandaPassRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT

            return wakandaPassRef as! &WakandaPass.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub fun createNewMinter(): @WakandaPass.NFTMinter {
        return <- create NFTMinter()
    }

    pub resource interface MinterPublic {
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: {String: String})
    }

    pub resource NFTMinter: MinterPublic {
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: {String: String}) {
            self.mintNFTWithCustomLockup(
                recipient: recipient,
                metadata: metadata,
                vault: <- WakandaToken.createEmptyVault(),
                lockupSchedule: {0.0: 0.0}
            )
        }

        pub fun mintNFTWithCustomLockup(
            recipient: &{NonFungibleToken.CollectionPublic},
            metadata: {String: String},
            vault: @FungibleToken.Vault,
            lockupSchedule: {UFix64: UFix64}
        ) {
            var newNFT <- create NFT(
                initID: WakandaPass.totalSupply,
                originalOwner: recipient.owner?.address,
                metadata: metadata,
                vault: <- vault,
                lockupSchedule: lockupSchedule
            )

            recipient.deposit(token: <-newNFT)
            WakandaPass.totalSupply = WakandaPass.totalSupply + UInt64(1)
        }
    }

    pub fun check(_ address: Address): Bool {
        let collection: Bool = getAccount(address)
            .getCapability<&{WakandaPass.CollectionPublic}>(WakandaPass.CollectionPublicPath)
            .check()

        let minter: Bool = getAccount(address)
            .getCapability<&{WakandaPass.MinterPublic}>(WakandaPass.MinterPublicPath)
            .check()

        return collection && minter
    }

    pub fun fetch(_ address: Address): &{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic} {
        return  getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()!
    }

    pub fun read(address: Address, id: UInt64): WakandaPass.ReadOnly? {
        if let collectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>() {
            let pass = collectionRef.borrowWakandaPassPublic(id: id).asReadOnly()
            if pass != nil {
                return pass
            }
        }
        return nil
    }

    init() {
        self.totalSupply = 0
        self.CollectionStoragePath = /storage/wakandaPassCollection
        self.CollectionPublicPath = /public/wakandaPassCollection
        self.MinterStoragePath = /storage/wakandaPassMinter
        self.MinterPublicPath = /public/wakandaPassMinter
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        self.account.link<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        self.account.link<&{WakandaPass.MinterPublic}>(
            self.MinterPublicPath,
            target: self.MinterStoragePath
        )

        emit ContractInitialized()
    }
}
