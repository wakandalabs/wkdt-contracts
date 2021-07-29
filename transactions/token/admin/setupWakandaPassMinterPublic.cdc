import WakandaPass from "../../../contracts/flow/token/WakandaPass.cdc"

transaction {
    prepare(signer: AuthAccount) {
        // create a public capability to mint Wakanda Pass
        signer.link<&{WakandaPass.MinterPublic}>(
            WakandaPass.MinterPublicPath,
            target: WakandaPass.MinterStoragePath
        )
    }
}