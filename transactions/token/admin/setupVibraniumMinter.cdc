import FungibleToken from "../../../contracts/flow/token/FungibleToken.cdc"
import Vibranium from "../../../contracts/flow/token/Vibranium.cdc"

transaction(allowedAmount: UFix64) {

    prepare(signer: AuthAccount) {
        let admin = signer
            .borrow<&Vibranium.Administrator>(from: /storage/vibraniumAdmin)
            ?? panic("Signer is not the admin")

        let minter <- admin.createNewMinter(allowedAmount: allowedAmount)

        signer.save(<-minter, to: Vibranium.TokenMinterStoragePath)
    }
}
