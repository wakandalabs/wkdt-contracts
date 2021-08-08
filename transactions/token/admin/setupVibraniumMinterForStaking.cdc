import FungibleToken from "../../../contracts/flow/token/FungibleToken.cdc"
import WakandaToken from "../../../contracts/flow/token/WakandaToken.cdc"

transaction(allowedAmount: UFix64) {

    prepare(signer: AuthAccount, minter: AuthAccount) {
        let admin = signer
            .borrow<&WakandaToken.Administrator>(from: /storage/wakandaTokenAdmin)
            ?? panic("Signer is not the admin")

        let minterResource <- admin.createNewMinter(allowedAmount: allowedAmount)

        minter.save(<-minterResource, to: WakandaToken.TokenMinterStoragePath)
    }
}