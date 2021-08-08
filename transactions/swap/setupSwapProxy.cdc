import WkdtUsdtSwapPair from "../../contracts/flow/swap/WkdtUsdtSwapPair.cdc"

transaction {
  let proxy: @WkdtUsdtSwapPair.SwapProxy
  let holder: AuthAccount

  prepare(swapContractAccount: AuthAccount, proxyHolder: AuthAccount) {
    let adminRef = swapContractAccount.borrow<&WkdtUsdtSwapPair.Admin>(from: /storage/wkdtUsdtPairAdmin)
      ?? panic("Could not borrow a reference to Admin")

    self.proxy <- adminRef.createSwapProxy()

    assert(self.proxy != nil, message: "loaded proxy resource is nil")

    self.holder = proxyHolder
  }

  execute {
    self.holder.save(<-self.proxy, to: /storage/wkdtUsdtSwapProxy)

    let newSwapProxyRef = self.holder
      .borrow<&WkdtUsdtSwapPair.SwapProxy>(from: /storage/wkdtUsdtSwapProxy)
      ?? panic("Could not borrow a reference to new proxy holder")
  }
}
