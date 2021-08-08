import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        admin.stopCollecting()
    }
}
