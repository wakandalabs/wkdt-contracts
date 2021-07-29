import FungibleToken from "../token/FungibleToken.cdc"
import NonFungibleToken from "../token/NonFungibleToken.cdc"
import Vibranium from "../token/Vibranium.cdc"
import WakandaPass from "../token/WakandaPass.cdc"

pub contract VibraniumMining {

    // Event that is emitted when mining state is updated
    pub event MiningStateUpdated(state: UInt8)

    // Event that is emitted when go to next round
    pub event RoundUpdated(round: UInt64)

    // Event that is emitted when reward cap is updated
    pub event RewardCapUpdated(rewardCap: UFix64)

    // Event that is emitted when cap multiplier is updated
    pub event CapMultiplierUpdated(capMultiplier: UInt64)

    // Event that is emitted when new criteria is updated
    pub event CriteriaUpdated(name: String, criteria: Criteria?)

    // Event that is emitted when reward lock period is updated
    pub event RewardLockPeriodUpdated(rewardLockPeriod: UInt64)

    // Event that is emitted when reward lock ratio is updated
    pub event RewardLockRatioUpdated(rewardLockRatio: UFix64)

    // Event that is emitted when mining raw data is collected
    pub event DataCollected(data: {String: UFix64}, address: Address, reward: UFix64, replacedReward: UFix64?)

    // Event that is emitted when reward is distributed
    pub event RewardDistributed(reward: UFix64, address: Address)

    // Event that is emiited when reward is withdrawn
    pub event RewardWithdrawn(amount: UFix64, from: Address?)

    // Criteria
    //
    // Define mining criteria
    //
    pub struct Criteria {

        // The reward a user can mine if achieving the goal
        pub var reward: UFix64

        // Divisor to adjust raw data
        pub var divisor: UFix64

        // Cap times in one round
        pub var capTimes: UInt64

        init(reward: UFix64, divisor: UFix64, capTimes: UInt64) {
            self.reward = reward
            self.divisor = divisor
            self.capTimes = capTimes
        }
    }

    // MiningState
    //
    // Define mining state
    //
    pub enum MiningState: UInt8 {
        pub case initial
        pub case collecting
        pub case collected
        pub case distributed
    }

    // Defines mining reward storage path
    pub let MiningRewardStoragePath: StoragePath

    // Defines mining reward public balance path
    pub let MiningRewardPublicPath: PublicPath

    // Define mining state
    access(contract) var miningState: MiningState

    // Define current round
    access(contract) var currentRound: UInt64

    // Define current total reward computed by users' raw data
    access(contract) var currentTotalReward: UFix64

    // Define reward cap
    access(contract) var rewardCap: UFix64

    // Define cap multipier for VIP-tier users
    access(contract) var capMultiplier: UInt64

    // Define mining criterias
    // criteria name => Criteria
    access(contract) var criterias: {String: Criteria}

    // Define reward lock period
    access(contract) var rewardLockPeriod: UInt64

    // Define reward lock ratio
    access(contract) var rewardLockRatio: UFix64

    // Define if user reward is collected
    // Address => round
    access(contract) var userRewardsCollected: {Address: UInt64}

    // Define user rewards in current round
    // This doesn't consider reward cap
    access(contract) var userRewards: {Address: UFix64}

    // Define if reward is distributed
    // Address => round
    access(contract) var rewardsDistributed: {Address: UInt64}

    // Administrator
    //
    pub resource Administrator {

        // Start collecting users' raw data
        pub fun startCollecting() {
            VibraniumMining.miningState = MiningState.collecting

            emit MiningStateUpdated(state: VibraniumMining.miningState.rawValue)
        }

        // Stop collecting users' raw data
        pub fun stopCollecting() {
            VibraniumMining.miningState = MiningState.collected

            emit MiningStateUpdated(state: VibraniumMining.miningState.rawValue)
        }

        // Finish distributing reward
        pub fun finishDistributing() {
            VibraniumMining.miningState = MiningState.distributed

            emit MiningStateUpdated(state: VibraniumMining.miningState.rawValue)
        }

        // Go to next round and reset total reward
        pub fun goNextRound() {
            pre {
                VibraniumMining.miningState == MiningState.initial ||
                    VibraniumMining.miningState == MiningState.distributed:
                    "Current round should be distributed"
            }
            VibraniumMining.currentRound = VibraniumMining.currentRound + (1 as UInt64)
            VibraniumMining.currentTotalReward = 0.0

            emit RoundUpdated(round: VibraniumMining.currentRound)

            self.startCollecting()
        }

        // Update reward cap
        pub fun updateRewardCap(_ rewardCap: UFix64) {
            VibraniumMining.rewardCap = rewardCap

            emit RewardCapUpdated(rewardCap: rewardCap)
        }

        // Update cap multiplier
        pub fun updateCapMultiplier(_ capMultiplier: UInt64) {
            pre {
                VibraniumMining.miningState == MiningState.initial ||
                    VibraniumMining.miningState == MiningState.collected:
                    "Current round should be collected"
            }
            VibraniumMining.capMultiplier = capMultiplier

            emit CapMultiplierUpdated(capMultiplier: capMultiplier)
        }

        // Update criteria by name
        pub fun updateCriteria(name: String, criteria: Criteria?) {
            pre {
                VibraniumMining.miningState == MiningState.initial ||
                    VibraniumMining.miningState == MiningState.collected:
                    "Current round should be collected"
            }
            VibraniumMining.criterias[name] = criteria

            emit CriteriaUpdated(name: name, criteria: criteria)
        }

        pub fun updateRewardLockPeriod(_ rewardLockPeriod: UInt64) {
            pre {
                VibraniumMining.miningState != MiningState.collected: "Should NOT be collected"
            }
            VibraniumMining.rewardLockPeriod = rewardLockPeriod

            emit RewardLockPeriodUpdated(rewardLockPeriod: rewardLockPeriod)
        }

        pub fun updateRewardLockRatio(_ rewardLockRatio: UFix64) {
            pre {
                VibraniumMining.miningState != MiningState.collected: "Should NOT be collected"
                rewardLockRatio <= 1.0: "ratio should be less than or equal to 1"
            }
            VibraniumMining.rewardLockRatio = rewardLockRatio

            emit RewardLockRatioUpdated(rewardLockRatio: rewardLockRatio)
        }

        // Collect raw data
        // data: {criteria name: raw data}
        pub fun collectData(_ data: {String: UFix64}, address: Address) {
            pre {
                VibraniumMining.miningState == MiningState.collecting: "Should start collecting"
            }

            // Check if the address has MiningRewardPublicPath
            let miningRewardRef = getAccount(address).getCapability(VibraniumMining.MiningRewardPublicPath)
                .borrow<&{VibraniumMining.MiningRewardPublic}>()
                ?? panic("Could not borrow mining reward public reference")

            let isVIP = VibraniumMining.isAddressVIP(address: address)
            let round = VibraniumMining.userRewardsCollected[address] ?? (0 as UInt64)
            if round < VibraniumMining.currentRound {
                let reward = VibraniumMining.computeReward(data: data, isVIP: isVIP)

                VibraniumMining.currentTotalReward = VibraniumMining.currentTotalReward + reward
                VibraniumMining.userRewards[address] = reward

                emit DataCollected(data: data, address: address, reward: reward, replacedReward: nil)
            } else if round == VibraniumMining.currentRound {
                let replacedReward = VibraniumMining.userRewards[address]!
                let reward = VibraniumMining.computeReward(data: data, isVIP: isVIP)

                VibraniumMining.currentTotalReward = VibraniumMining.currentTotalReward - replacedReward + reward
                VibraniumMining.userRewards[address] = reward

                emit DataCollected(data: data, address: address, reward: reward, replacedReward: replacedReward)
            } else {
                panic("Reward collected round must less than or equal to current round")
            }

            VibraniumMining.userRewardsCollected[address] = VibraniumMining.currentRound
        }

        // Distribute reward by address
        pub fun distributeReward(address: Address) {
            pre {
                VibraniumMining.miningState == MiningState.collected: "Should stop collecting"
                VibraniumMining.rewardsDistributed[address] ?? (0 as UInt64) < VibraniumMining.currentRound:
                    "Same address in currrent round already distributed"
            }
            post {
                VibraniumMining.rewardsDistributed[address] == VibraniumMining.currentRound:
                    "Same address in currrent round should be distributed"
            }

            let reward = VibraniumMining.computeFinalReward(
                address: address,
                totalReward: VibraniumMining.currentTotalReward)
            let vibraniumMinter = VibraniumMining.account.borrow<&Vibranium.Minter>(from: Vibranium.TokenMinterStoragePath)
                ?? panic("Could not borrow minter reference")
            let rewardVault <- vibraniumMinter.mintTokens(amount: reward)

            let lockReward = reward * VibraniumMining.rewardLockRatio
            let lockRewardVault <- rewardVault.withdraw(amount: lockReward) as! @Vibranium.Vault
            let lockRound = VibraniumMining.currentRound + VibraniumMining.rewardLockPeriod

            let miningRewardRef = getAccount(address).getCapability(VibraniumMining.MiningRewardPublicPath)
                .borrow<&{VibraniumMining.MiningRewardPublic}>()
                ?? panic("Could not borrow mining reward public reference")
            miningRewardRef.deposit(reward: <- lockRewardVault, lockRound: lockRound)
            miningRewardRef.deposit(reward: <- rewardVault, lockRound: VibraniumMining.currentRound)

            VibraniumMining.rewardsDistributed[address] = VibraniumMining.currentRound

            emit RewardDistributed(reward: reward, address: address)
        }

        access(self) fun getHighestTierWakandaPass(address: Address): &WakandaPass.NFT{NonFungibleToken.INFT}? {
            let collectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
                .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
                ?? panic("Could not borrow collection public reference")

            var highestTier: UInt64? = nil
            var highestWakandaPass: &WakandaPass.NFT{NonFungibleToken.INFT}? = nil
            for id in collectionRef.getIDs() {
                let wakandaPass = collectionRef.borrowWakandaPassPublic(id: id)
                let tier = wakandaPass.getVipTier()
                if let localHighestTier = highestTier {
                    if tier > localHighestTier {
                        highestTier = tier
                        highestWakandaPass = wakandaPass
                    }
                } else {
                    highestTier = tier
                    highestWakandaPass = wakandaPass
                }
            }
            return highestWakandaPass
        }
    }

    pub resource interface MiningRewardPublic {
        pub fun getRewardsLocked(): {UInt64: UFix64}
        pub fun computeUnlocked(): UFix64
        access(contract) fun deposit(reward: @Vibranium.Vault, lockRound: UInt64)
    }

    pub resource MiningReward: MiningRewardPublic {

        // round => reward
        access(self) var rewardsLocked: {UInt64: UFix64}

        // Define reward lock vault
        access(self) let reward: @Vibranium.Vault

        pub fun getRewardsLocked(): {UInt64: UFix64} {
            return self.rewardsLocked
        }

        pub fun computeUnlocked(): UFix64 {
            var amount: UFix64 = 0.0
            for round in self.rewardsLocked.keys {
                if round < VibraniumMining.currentRound {
                    amount = amount + self.rewardsLocked[round]!
                }
            }
            return amount
        }

        access(contract) fun deposit(reward: @Vibranium.Vault, lockRound: UInt64) {
            self.rewardsLocked[lockRound] = (self.rewardsLocked[lockRound] ?? 0.0) + reward.balance
            self.reward.deposit(from: <- reward)
        }

        pub fun withdraw(): @Vibranium.Vault {
            var amount: UFix64 = 0.0
            for round in self.rewardsLocked.keys {
                if round < VibraniumMining.currentRound {
                    amount = amount + self.rewardsLocked.remove(key: round)!
                }
            }
            emit RewardWithdrawn(amount: amount, from: self.owner?.address)
            return <- (self.reward.withdraw(amount: amount) as! @Vibranium.Vault)
        }

        init() {
            self.rewardsLocked = {}
            self.reward <- Vibranium.createEmptyVault() as! @Vibranium.Vault
        }

        destroy() {
            destroy self.reward
        }
    }

    pub fun getMiningState(): MiningState {
        return self.miningState
    }

    pub fun getCurrentRound(): UInt64 {
        return self.currentRound
    }

    pub fun getCurrentTotalReward(): UFix64 {
        return self.currentTotalReward
    }

    pub fun getRewardCap(): UFix64 {
        return self.rewardCap
    }

    pub fun getCapMultiplier(): UInt64 {
        return self.capMultiplier
    }

    pub fun getCriterias(): {String: Criteria} {
        return self.criterias
    }

    pub fun getRewardLockPeriod(): UInt64 {
        return self.rewardLockPeriod
    }

    pub fun getRewardLockRatio(): UFix64 {
        return self.rewardLockRatio
    }

    pub fun getUserRewardsCollected(): {Address: UInt64} {
        return self.userRewardsCollected
    }

    pub fun getUserRewards(): {Address: UFix64} {
        return self.userRewards
    }

    pub fun getRewardsDistributed(): {Address: UInt64} {
        return self.rewardsDistributed
    }

    // Chceck if the address is VIP
    pub fun isAddressVIP(address: Address): Bool {
        let collectionRef = getAccount(address).getCapability(WakandaPass.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, WakandaPass.CollectionPublic}>()
            ?? panic("Could not borrow collection public reference")

        for id in collectionRef.getIDs() {
            let wakandaPass = collectionRef.borrowWakandaPassPublic(id: id)
            if wakandaPass.getVipTier() > (0 as UInt64) {
                return true
            }
        }
        return false
    }

    // Compute reward in current round without reward cap
    pub fun computeReward(data: {String: UFix64}, isVIP: Bool): UFix64 {
        var reward: UFix64 = 0.0
        for name in data.keys {
            let value = data[name]!
            let criteria = self.criterias[name]!

            var capTimes = criteria.capTimes
            if isVIP {
                capTimes = criteria.capTimes * self.capMultiplier
            }
            var times = UInt64(value / criteria.divisor)
            if times > capTimes {
                times = capTimes
            }

            reward = reward + UFix64(times) * criteria.reward
        }
        return reward
    }

    // Compute final reward in current round with reward cap
    pub fun computeFinalReward(address: Address, totalReward: UFix64): UFix64 {
        var reward = self.userRewards[address] ?? 0.0
        if totalReward > self.rewardCap {
            reward = reward * self.rewardCap / totalReward
        }
        return reward
    }

    pub fun createEmptyMiningReward(): @MiningReward {
        return <- create MiningReward()
    }

    init() {
        self.MiningRewardStoragePath = /storage/vibraniumMiningReward
        self.MiningRewardPublicPath = /public/vibraniumMiningReward
        self.miningState = MiningState.initial
        self.currentRound = 0
        self.currentTotalReward = 0.0
        self.rewardCap = 62_500_000.0 / 4.0 / 52.0
        self.capMultiplier = 3
        self.criterias = {}
        self.rewardLockPeriod = 4
        self.rewardLockRatio = 0.5
        self.userRewardsCollected = {}
        self.userRewards = {}
        self.rewardsDistributed = {}

        let admin <- create Administrator()
        self.account.save(<-admin, to: /storage/vibraniumMiningAdmin)
    }
}