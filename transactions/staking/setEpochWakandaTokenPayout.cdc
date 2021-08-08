import WakandaTokenStaking from "../../contracts/flow/staking/WakandaTokenStaking.cdc"

transaction(amount: UFix64) {

    // Local variable for a reference to the ID Table Admin object
    let adminRef: &WakandaTokenStaking.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the admin object
        self.adminRef = acct.borrow<&WakandaTokenStaking.Admin>(from: WakandaTokenStaking.StakingAdminStoragePath)
            ?? panic("Could not borrow reference to staking admin")
    }

    execute {
        self.adminRef.setEpochTokenPayout(amount)
    }
}
