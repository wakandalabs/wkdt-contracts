import WakandaTokenMining from "../../contracts/flow/mining/WakandaTokenMining.cdc"

transaction(name: String) {

    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaTokenMining.Administrator>(from: /storage/wakandaTokenMiningAdmin)
            ?? panic("Signer is not the admin")

        admin.updateCriteria(name: name, criteria: nil)
    }
}
