import WkdtUsdtSwapPair from "../../contracts/flow/swap/WkdtUsdtSwapPair.cdc"

transaction() {
  prepare(swapPairAdmin: AuthAccount) {

    let adminRef = swapPairAdmin.borrow<&WkdtUsdtSwapPair.Admin>(from: /storage/wkdtUsdtPairAdmin)
        ?? panic("Could not borrow a reference to Admin")

    adminRef.freeze()
  }
}
