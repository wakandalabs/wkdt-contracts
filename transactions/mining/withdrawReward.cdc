import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"
import WakandaToken from "../../contracts/flow/token/WakandaToken.cdc"

transaction {

    prepare(signer: AuthAccount) {
        let vaultRef = signer.borrow<&WakandaToken.Vault>(from: WakandaToken.TokenStoragePath)
            ?? panic("Could not borrow reference to the owner's Vault!")

        let miningRewardRef = signer.borrow<&WakandaTokenMining.MiningReward>(from: WakandaTokenMining.MiningRewardStoragePath)
            ?? panic("Could not borrow reference to the owner's mining reward!")

        let rewardVault <- miningRewardRef.withdraw()
        vaultRef.deposit(from: <- rewardVault)
    }
}