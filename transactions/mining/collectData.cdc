import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction(address: Address, tx: UFix64, referral: UFix64, assetInCirculation: UFix64) {

    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        let data = {
            "tx": tx,
            "referral": referral,
            "assetInCirculation": assetInCirculation
        }

        admin.collectData(data, address: address)
    }
}
