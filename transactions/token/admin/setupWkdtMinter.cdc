import FungibleToken from "../../../contracts/flow/token/FungibleToken.cdc"
import WakandaToken from "../../../contracts/flow/token/WakandaToken.cdc"

transaction(allowedAmount: UFix64) {

    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&WakandaToken.Administrator>(from: /storage/wakandaTokenAdmin)
            ?? panic("Signer is not the admin")

        let minter <- admin.createNewMinter(allowedAmount: allowedAmount)

        signer.save(<-minter, to: WakandaToken.TokenMinterStoragePath)
    }
}
