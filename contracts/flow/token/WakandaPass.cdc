// This is the implementation of WakandaPass, the Wakanda Non-Fungible Token
// that is used in-conjunction with VIBRA, the Wakanda Fungible Token

import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import Vibranium from "./Vibranium.cdc"
import VibraniumStaking from "../staking/VibraniumStaking.cdc"
import WakandaPassStamp from "./WakandaPassStamp.cdc"

pub contract WakandaPass: NonFungibleToken {

    pub var totalSupply: UInt64
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath
    pub let MinterPublicPath: PublicPath

    // pre-defined lockup schedules
    // key: timestamp
    // value: percentage of VIBRA that must remain in the WakandaPass at this timestamp
    access(contract) var predefinedLockupSchedules: [{UFix64: UFix64}]

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event LockupScheduleDefined(id: Int, lockupSchedule: {UFix64: UFix64})
    pub event LockupScheduleUpdated(id: Int, lockupSchedule: {UFix64: UFix64})

    pub resource interface WakandaPassPrivate {
        pub fun stakeNewTokens(amount: UFix64)
        pub fun stakeUnstakedTokens(amount: UFix64)
        pub fun stakeRewardedTokens(amount: UFix64)
        pub fun requestUnstaking(amount: UFix64)
        pub fun unstakeAll()
        pub fun withdrawUnstakedTokens(amount: UFix64)
        pub fun withdrawRewardedTokens(amount: UFix64)
        pub fun withdrawAllUnlockedTokens(): @FungibleToken.Vault
        pub fun stampWakandaPass(from: @WakandaPassStamp.NFT)
    }

    pub resource interface WakandaPassPublic {
        pub fun getOriginalOwner(): Address?
        pub fun getMetadata(): {String: String}
        pub fun getStamps(): [String]
        pub fun getVipTier(): UInt64
        pub fun getStakingInfo(): VibraniumStaking.StakerInfo
        pub fun getLockupSchedule(): {UFix64: UFix64}
        pub fun getLockupAmountAtTimestamp(timestamp: UFix64): UFix64
        pub fun getLockupAmount(): UFix64
        pub fun getIdleBalance(): UFix64
        pub fun getTotalBalance(): UFix64
    }

    pub resource NFT:
        NonFungibleToken.INFT,
        FungibleToken.Provider,
        FungibleToken.Receiver,
        WakandaPassPrivate,
        WakandaPassPublic
    {
        // VIBRA holder vault
        access(self) let vault: @Vibranium.Vault

        // VIBRA staker handle
        access(self) let staker: @VibraniumStaking.Staker

        // WakandaPass ID
        pub let id: UInt64

        // WakandaPass owner address
        // If the pass is transferred to another user, some perks will be disabled
        pub let originalOwner: Address?

        // WakandaPass metadata
        access(self) var metadata: {String: String}

        // WakandaPass usage stamps, including voting records and special events
        access(self) var stamps: [String]

        // Total amount that's subject to lockup schedule
        pub let lockupAmount: UFix64

        // ID of predefined lockup schedule
        // If lockupScheduleId == nil, use custom lockup schedule instead
        pub let lockupScheduleId: Int?

        // Defines how much Vibranium must remain in the WakandaPass on different dates
        // key: timestamp
        // value: percentage of VIBRA that must remain in the WakandaPass at this timestamp
        access(self) let lockupSchedule: {UFix64: UFix64}?

        init(
            initID: UInt64,
            originalOwner: Address?,
            metadata: {String: String},
            vault: @FungibleToken.Vault,
            lockupScheduleId: Int?,
            lockupSchedule: {UFix64: UFix64}?
        ) {
            let stakingAdmin = WakandaPass.account.borrow<&VibraniumStaking.Admin>(from: VibraniumStaking.StakingAdminStoragePath)
                ?? panic("Could not borrow admin reference")

            self.id = initID
            self.originalOwner = originalOwner
            self.metadata = metadata
            self.stamps = []
            self.vault <- vault as! @Vibranium.Vault
            self.staker <- stakingAdmin.addStakerRecord(id: initID)

            // lockup calculations
            self.lockupAmount = self.vault.balance
            self.lockupScheduleId = lockupScheduleId
            self.lockupSchedule = lockupSchedule
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            post {
                self.getTotalBalance() >= self.getLockupAmount(): "Cannot withdraw locked-up VIBRAs"
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

        pub fun getStamps(): [String] {
            return self.stamps
        }

        pub fun getVipTier(): UInt64 {
            // Disable VIP tier at launch

            // let stakedAmount = self.getStakingInfo().tokensStaked
            // if stakedAmount >= 1000.0 {
            //     return 1
            // }
            
            // TODO: add more tiers
            
            return 0
        }

        pub fun getLockupSchedule(): {UFix64: UFix64} {
            if self.lockupScheduleId == nil {
                return self.lockupSchedule ?? {0.0: 0.0}
            }

            return WakandaPass.predefinedLockupSchedules[self.lockupScheduleId!]
        }

        pub fun getStakingInfo(): VibraniumStaking.StakerInfo {
            return VibraniumStaking.StakerInfo(stakerID: self.id)
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

        pub fun getTotalBalance(): UFix64 {
            return self.getIdleBalance() + VibraniumStaking.StakerInfo(self.id).totalTokensInRecord()
        }

        // Private staking methods
        pub fun stakeNewTokens(amount: UFix64) {
            self.staker.stakeNewTokens(<- self.vault.withdraw(amount: amount))
        }

        pub fun stakeUnstakedTokens(amount: UFix64) {
            self.staker.stakeUnstakedTokens(amount: amount)
        }

        pub fun stakeRewardedTokens(amount: UFix64) {
            self.staker.stakeRewardedTokens(amount: amount)
        }

        pub fun requestUnstaking(amount: UFix64) {
            self.staker.requestUnstaking(amount: amount)
        }

        pub fun unstakeAll() {
            self.staker.unstakeAll()
        }

        pub fun withdrawUnstakedTokens(amount: UFix64) {
            let vault <- self.staker.withdrawUnstakedTokens(amount: amount)
            self.vault.deposit(from: <- vault)
        }

        pub fun withdrawRewardedTokens(amount: UFix64) {
            let vault <- self.staker.withdrawRewardedTokens(amount: amount)
            self.vault.deposit(from: <- vault)
        }

        pub fun withdrawAllUnlockedTokens(): @FungibleToken.Vault {
            let unlockedAmount = self.getTotalBalance() - self.getLockupAmount()
            let withdrawAmount = unlockedAmount < self.getIdleBalance() ? unlockedAmount : self.getIdleBalance()
            return <- self.vault.withdraw(amount: withdrawAmount)
        }

        pub fun stampWakandaPass(from: @WakandaPassStamp.NFT) {
            self.stamps.append(from.getMessage())
            destroy from
        }

        destroy() {
            destroy self.vault
            destroy self.staker
        }
    }

    // CollectionPublic is a custom interface that allows us to
    // access the public fields and methods for our WakandaPass Collection
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
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        // withdrawal is disabled during lockup period
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @WakandaPass.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowWakandaPassPublic gets the public references to a WakandaPass NFT in the collection
        // and returns it to the caller as a reference to the NFT
        pub fun borrowWakandaPassPublic(id: UInt64): &WakandaPass.NFT{WakandaPass.WakandaPassPublic, FungibleToken.Receiver, NonFungibleToken.INFT} {
            let wakandaPassRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let intermediateRef = wakandaPassRef as! auth &WakandaPass.NFT

            return intermediateRef as &WakandaPass.NFT{WakandaPass.WakandaPassPublic, FungibleToken.Receiver, NonFungibleToken.INFT}
        }

        // borrowWakandaPassPublic gets the public references to a WakandaPass NFT in the collection
        // and returns it to the caller as a reference to the NFT
        pub fun borrowWakandaPassPrivate(id: UInt64): &WakandaPass.NFT {
            let wakandaPassRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT

            return wakandaPassRef as! &WakandaPass.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource interface MinterPublic {
        pub fun mintBasicNFT(recipient: &{NonFungibleToken.CollectionPublic})
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter: MinterPublic {

        // adds a new predefined lockup schedule
        pub fun setupPredefinedLockupSchedule(lockupSchedule: {UFix64: UFix64}) {
            WakandaPass.predefinedLockupSchedules.append(lockupSchedule)

            emit LockupScheduleDefined(id: WakandaPass.predefinedLockupSchedules.length, lockupSchedule: lockupSchedule)
        }

        // updates a predefined lockup schedule
        // note that this function should be avoided 
        pub fun updatePredefinedLockupSchedule(id: Int, lockupSchedule: {UFix64: UFix64}) {
            WakandaPass.predefinedLockupSchedules[id] = lockupSchedule

            emit LockupScheduleUpdated(id: id, lockupSchedule: lockupSchedule)
        }

        // mintBasicNFT mints a new NFT without any special metadata or lockups
        pub fun mintBasicNFT(recipient: &{NonFungibleToken.CollectionPublic}) {
            self.mintNFT(recipient: recipient, metadata: {})
        }

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, metadata: {String: String}) {
            self.mintNFTWithCustomLockup(
                recipient: recipient,
                metadata: metadata,
                vault: <- Vibranium.createEmptyVault(),
                lockupSchedule: {0.0: 0.0}
            )
        }

        pub fun mintNFTWithPredefinedLockup(
            recipient: &{NonFungibleToken.CollectionPublic},
            metadata: {String: String},
            vault: @FungibleToken.Vault,
            lockupScheduleId: Int?
        ) {

            // create a new NFT
            var newNFT <- create NFT(
                initID: WakandaPass.totalSupply,
                originalOwner: recipient.owner?.address,
                metadata: metadata,
                vault: <- vault,
                lockupScheduleId: lockupScheduleId,
                lockupSchedule: nil
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            WakandaPass.totalSupply = WakandaPass.totalSupply + UInt64(1)
        }

        pub fun mintNFTWithCustomLockup(
            recipient: &{NonFungibleToken.CollectionPublic},
            metadata: {String: String},
            vault: @FungibleToken.Vault,
            lockupSchedule: {UFix64: UFix64}
        ) {

            // create a new NFT
            var newNFT <- create NFT(
                initID: WakandaPass.totalSupply,
                originalOwner: recipient.owner?.address,
                metadata: metadata,
                vault: <- vault,
                lockupScheduleId: nil,
                lockupSchedule: lockupSchedule
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            WakandaPass.totalSupply = WakandaPass.totalSupply + UInt64(1)
        }
    }

    pub fun getPredefinedLockupSchedule(id: Int): {UFix64: UFix64} {
        return self.predefinedLockupSchedules[id]
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0
        self.predefinedLockupSchedules = []

        self.CollectionStoragePath = /storage/wakandaPassCollection
        self.CollectionPublicPath = /public/wakandaPassCollection
        self.MinterStoragePath = /storage/wakandaPassMinter
        self.MinterPublicPath = /public/wakandaPassMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}
