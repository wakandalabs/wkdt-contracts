import FungibleToken from "../token/FungibleToken.cdc"
import WakandaToken from "../token/WakandaToken.cdc"
import TeleportedTetherToken from "../token/TeleportedTetherToken.cdc"

// Exchange pair between WakandaToken and TeleportedTetherToken
// Token1: WakandaToken
// Token2: TeleportedTetherToken
pub contract WkdtUsdtSwapPair: FungibleToken {
  // Frozen flag controlled by Admin
  pub var isFrozen: Bool

  // Total supply of WkdtUsdtSwapPair liquidity token in existence
  pub var totalSupply: UFix64

  // Fee charged when performing token swap
  pub var feePercentage: UFix64

  // Controls WakandaToken vault
  access(contract) let token1Vault: @WakandaToken.Vault

  // Controls TeleportedTetherToken vault
  access(contract) let token2Vault: @TeleportedTetherToken.Vault

  // Defines token vault storage path
  pub let TokenStoragePath: StoragePath

  // Defines token vault public balance path
  pub let TokenPublicBalancePath: PublicPath

  // Defines token vault public receiver path
  pub let TokenPublicReceiverPath: PublicPath

  // Event that is emitted when the contract is created
  pub event TokensInitialized(initialSupply: UFix64)

  // Event that is emitted when tokens are withdrawn from a Vault
  pub event TokensWithdrawn(amount: UFix64, from: Address?)

  // Event that is emitted when tokens are deposited to a Vault
  pub event TokensDeposited(amount: UFix64, to: Address?)

  // Event that is emitted when new tokens are minted
  pub event TokensMinted(amount: UFix64)

  // Event that is emitted when tokens are destroyed
  pub event TokensBurned(amount: UFix64)

  // Event that is emitted when trading fee is updated
  pub event FeeUpdated(feePercentage: UFix64)

  // Event that is emitted when a swap happens
  // Side 1: from token1 to token2
  // Side 2: from token2 to token1
  pub event Trade(token1Amount: UFix64, token2Amount: UFix64, side: UInt8)

  // Vault
  //
  // Each user stores an instance of only the Vault in their storage
  // The functions in the Vault and governed by the pre and post conditions
  // in WkdtUsdtSwapPair when they are called.
  // The checks happen at runtime whenever a function is called.
  //
  // Resources can only be created in the context of the contract that they
  // are defined in, so there is no way for a malicious user to create Vaults
  // out of thin air. A special Minter resource needs to be defined to mint
  // new tokens.
  //
  pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

    // holds the balance of a users tokens
    pub var balance: UFix64

    // initialize the balance at resource creation time
    init(balance: UFix64) {
      self.balance = balance
    }

    // withdraw
    //
    // Function that takes an integer amount as an argument
    // and withdraws that amount from the Vault.
    // It creates a new temporary Vault that is used to hold
    // the money that is being transferred. It returns the newly
    // created Vault to the context that called so it can be deposited
    // elsewhere.
    //
    pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
      self.balance = self.balance - amount
      emit TokensWithdrawn(amount: amount, from: self.owner?.address)
      return <-create Vault(balance: amount)
    }

    // deposit
    //
    // Function that takes a Vault object as an argument and adds
    // its balance to the balance of the owners Vault.
    // It is allowed to destroy the sent Vault because the Vault
    // was a temporary holder of the tokens. The Vault's balance has
    // been consumed and therefore can be destroyed.
    pub fun deposit(from: @FungibleToken.Vault) {
      let vault <- from as! @WkdtUsdtSwapPair.Vault
      self.balance = self.balance + vault.balance
      emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
      vault.balance = 0.0
      destroy vault
    }

    destroy() {
      WkdtUsdtSwapPair.totalSupply = WkdtUsdtSwapPair.totalSupply - self.balance
    }
  }

  // createEmptyVault
  //
  // Function that creates a new Vault with a balance of zero
  // and returns it to the calling context. A user must call this function
  // and store the returned Vault in their storage in order to allow their
  // account to be able to receive deposits of this token type.
  //
  pub fun createEmptyVault(): @FungibleToken.Vault {
    return <-create Vault(balance: 0.0)
  }

  pub resource TokenBundle {
    pub var token1: @WakandaToken.Vault
    pub var token2: @TeleportedTetherToken.Vault

    // initialize the vault bundle
    init(fromToken1: @WakandaToken.Vault, fromToken2: @TeleportedTetherToken.Vault) {
      self.token1 <- fromToken1
      self.token2 <- fromToken2
    }

    pub fun depositToken1(from: @WakandaToken.Vault) {
      self.token1.deposit(from: <- from)
    }

    pub fun depositToken2(from: @TeleportedTetherToken.Vault) {
      self.token2.deposit(from: <- from)
    }

    pub fun withdrawToken1(): @WakandaToken.Vault {
      var vault <- WakandaToken.createEmptyVault() as! @WakandaToken.Vault
      vault <-> self.token1
      return <- vault
    }

    pub fun withdrawToken2(): @TeleportedTetherToken.Vault {
      var vault <- TeleportedTetherToken.createEmptyVault() as! @TeleportedTetherToken.Vault
      vault <-> self.token2
      return <- vault
    }

    destroy() {
      destroy self.token1
      destroy self.token2
    }
  }

  // createEmptyBundle
  //
  pub fun createEmptyTokenBundle(): @WkdtUsdtSwapPair.TokenBundle {
    return <- create TokenBundle(
      fromToken1: <- (WakandaToken.createEmptyVault() as! @WakandaToken.Vault),
      fromToken2: <- (TeleportedTetherToken.createEmptyVault() as! @TeleportedTetherToken.Vault)
    )
  }

  // createTokenBundle
  //
  pub fun createTokenBundle(fromToken1: @WakandaToken.Vault, fromToken2: @TeleportedTetherToken.Vault): @WkdtUsdtSwapPair.TokenBundle {
    return <- create TokenBundle(fromToken1: <- fromToken1, fromToken2: <- fromToken2)
  }

  // mintTokens
  //
  // Function that mints new tokens, adds them to the total supply,
  // and returns them to the calling context.
  //
  access(contract) fun mintTokens(amount: UFix64): @WkdtUsdtSwapPair.Vault {
    pre {
      amount > UFix64(0): "Amount minted must be greater than zero"
    }
    WkdtUsdtSwapPair.totalSupply = WkdtUsdtSwapPair.totalSupply + amount
    emit TokensMinted(amount: amount)
    return <-create Vault(balance: amount)
  }

  // burnTokens
  //
  // Function that destroys a Vault instance, effectively burning the tokens.
  //
  // Note: the burned tokens are automatically subtracted from the
  // total supply in the Vault destructor.
  //
  access(contract) fun burnTokens(from: @WkdtUsdtSwapPair.Vault) {
    let vault <- from as! @WkdtUsdtSwapPair.Vault
    let amount = vault.balance
    destroy vault
    emit TokensBurned(amount: amount)
  }

  pub resource SwapProxy {
    pub fun swapToken1ForToken2(from: @WakandaToken.Vault): @TeleportedTetherToken.Vault {
      return <- WkdtUsdtSwapPair.swapToken1ForToken2(from: <-from)
    }

    pub fun swapToken2ForToken1(from: @TeleportedTetherToken.Vault): @WakandaToken.Vault {
      return <- WkdtUsdtSwapPair.swapToken2ForToken1(from: <-from)
    }

    pub fun addLiquidity(from: @WkdtUsdtSwapPair.TokenBundle): @WkdtUsdtSwapPair.Vault {
      return <- WkdtUsdtSwapPair.addLiquidity(from: <-from)
    }

    pub fun removeLiquidity(from: @WkdtUsdtSwapPair.Vault): @WkdtUsdtSwapPair.TokenBundle {
      return <- WkdtUsdtSwapPair.removeLiquidity(from: <-from)
    }
  }

  pub resource Admin {
    pub fun freeze() {
      WkdtUsdtSwapPair.isFrozen = true
    }

    pub fun unfreeze() {
      WkdtUsdtSwapPair.isFrozen = false
    }

    pub fun addInitialLiquidity(from: @WkdtUsdtSwapPair.TokenBundle): @WkdtUsdtSwapPair.Vault {
      pre {
        WkdtUsdtSwapPair.totalSupply == UFix64(0): "Pair already initialized"
      }

      let token1Vault <- from.withdrawToken1()
      let token2Vault <- from.withdrawToken2()

      assert(token1Vault.balance > UFix64(0), message: "Empty token1 vault")
      assert(token2Vault.balance > UFix64(0), message: "Empty token2 vault")

      WkdtUsdtSwapPair.token1Vault.deposit(from: <- token1Vault)
      WkdtUsdtSwapPair.token2Vault.deposit(from: <- token2Vault)

      destroy from

      // Create initial tokens
      return <- WkdtUsdtSwapPair.mintTokens(amount: 1.0)
    }

    pub fun updateFeePercentage(feePercentage: UFix64) {
      WkdtUsdtSwapPair.feePercentage = feePercentage

      emit FeeUpdated(feePercentage: feePercentage)
    }

    pub fun createSwapProxy(): @WkdtUsdtSwapPair.SwapProxy {
      return <- create WkdtUsdtSwapPair.SwapProxy()
    }
  }

  pub struct PoolAmounts {
    pub let token1Amount: UFix64
    pub let token2Amount: UFix64

    init(token1Amount: UFix64, token2Amount: UFix64) {
      self.token1Amount = token1Amount
      self.token2Amount = token2Amount
    }
  }

  // Check current pool amounts
  pub fun getPoolAmounts(): PoolAmounts {
    return PoolAmounts(token1Amount: WkdtUsdtSwapPair.token1Vault.balance, token2Amount: WkdtUsdtSwapPair.token2Vault.balance)
  }

  // Get quote for Token1 (given) -> Token2
  pub fun quoteSwapExactToken1ForToken2(amount: UFix64): UFix64 {
    let poolAmounts = self.getPoolAmounts()

    // token1Amount * token2Amount = token1Amount' * token2Amount' = (token1Amount + amount) * (token2Amount - quote)
    let quote = poolAmounts.token2Amount * amount / (poolAmounts.token1Amount + amount);

    return quote
  }

  // Get quote for Token1 -> Token2 (given)
  pub fun quoteSwapToken1ForExactToken2(amount: UFix64): UFix64 {
    let poolAmounts = self.getPoolAmounts()

    assert(poolAmounts.token2Amount > amount, message: "Not enough Token2 in the pool")

    // token1Amount * token2Amount = token1Amount' * token2Amount' = (token1Amount + quote) * (token2Amount - amount)
    let quote = poolAmounts.token1Amount * amount / (poolAmounts.token2Amount - amount);

    return quote
  }

  // Get quote for Token2 (given) -> Token1
  pub fun quoteSwapExactToken2ForToken1(amount: UFix64): UFix64 {
    let poolAmounts = self.getPoolAmounts()

    // token1Amount * token2Amount = token1Amount' * token2Amount' = (token2Amount + amount) * (token1Amount - quote)
    let quote = poolAmounts.token1Amount * amount / (poolAmounts.token2Amount + amount);

    return quote
  }

  // Get quote for Token2 -> Token1 (given)
  pub fun quoteSwapToken2ForExactToken1(amount: UFix64): UFix64 {
    let poolAmounts = self.getPoolAmounts()

    assert(poolAmounts.token1Amount > amount, message: "Not enough Token1 in the pool")

    // token1Amount * token2Amount = token1Amount' * token2Amount' = (token2Amount + quote) * (token1Amount - amount)
    let quote = poolAmounts.token2Amount * amount / (poolAmounts.token1Amount - amount);

    return quote
  }

  // Swaps Token1 (WKDT) -> Token2 (tUSDT)
  access(contract) fun swapToken1ForToken2(from: @WakandaToken.Vault): @TeleportedTetherToken.Vault {
    pre {
      !WkdtUsdtSwapPair.isFrozen: "WkdtUsdtSwapPair is frozen"
      from.balance > UFix64(0): "Empty token vault"
    }

    // Calculate amount from pricing curve
    // A fee portion is taken from the final amount
    let token1Amount = from.balance * (1.0 - self.feePercentage)
    let token2Amount = self.quoteSwapExactToken1ForToken2(amount: token1Amount)

    assert(token2Amount > UFix64(0), message: "Exchanged amount too small")

    self.token1Vault.deposit(from: <- (from as! @FungibleToken.Vault))
    emit Trade(token1Amount: token1Amount, token2Amount: token2Amount, side: 1)

    return <- (self.token2Vault.withdraw(amount: token2Amount) as! @TeleportedTetherToken.Vault)
  }

  // Swap Token2 (tUSDT) -> Token1 (WKDT)
  access(contract) fun swapToken2ForToken1(from: @TeleportedTetherToken.Vault): @WakandaToken.Vault {
    pre {
      !WkdtUsdtSwapPair.isFrozen: "WkdtUsdtSwapPair is frozen"
      from.balance > UFix64(0): "Empty token vault"
    }

    // Calculate amount from pricing curve
    // A fee portion is taken from the final amount
    let token2Amount = from.balance * (1.0 - self.feePercentage)
    let token1Amount = self.quoteSwapExactToken2ForToken1(amount: token2Amount)

    assert(token1Amount > UFix64(0), message: "Exchanged amount too small")

    self.token2Vault.deposit(from: <- (from as! @FungibleToken.Vault))
    emit Trade(token1Amount: token1Amount, token2Amount: token2Amount, side: 2)

    return <- (self.token1Vault.withdraw(amount: token1Amount) as! @WakandaToken.Vault)
  }

  // Used to add liquidity without minting new liquidity token
  pub fun donateLiquidity(from: @WkdtUsdtSwapPair.TokenBundle) {
    let token1Vault <- from.withdrawToken1()
    let token2Vault <- from.withdrawToken2()

    WkdtUsdtSwapPair.token1Vault.deposit(from: <- token1Vault)
    WkdtUsdtSwapPair.token2Vault.deposit(from: <- token2Vault)

    destroy from
  }

  access(contract) fun addLiquidity(from: @WkdtUsdtSwapPair.TokenBundle): @WkdtUsdtSwapPair.Vault {
    pre {
      self.totalSupply > UFix64(0): "Pair must be initialized by admin first"
    }

    let token1Vault <- from.withdrawToken1()
    let token2Vault <- from.withdrawToken2()

    assert(token1Vault.balance > UFix64(0), message: "Empty token1 vault")
    assert(token2Vault.balance > UFix64(0), message: "Empty token2 vault")

    // shift decimal 4 places to avoid truncation error
    let token1Percentage: UFix64 = (token1Vault.balance * 10000.0) / WkdtUsdtSwapPair.token1Vault.balance
    let token2Percentage: UFix64 = (token2Vault.balance * 10000.0) / WkdtUsdtSwapPair.token2Vault.balance

    // final liquidity token minted is the smaller between token1Liquidity and token2Liquidity
    // to maximize profit, user should add liquidity proportional to current liquidity
    let liquidityPercentage = token1Percentage < token2Percentage ? token1Percentage : token2Percentage;

    assert(liquidityPercentage > UFix64(0), message: "Liquidity too small")

    WkdtUsdtSwapPair.token1Vault.deposit(from: <- token1Vault)
    WkdtUsdtSwapPair.token2Vault.deposit(from: <- token2Vault)

    let liquidityTokenVault <- WkdtUsdtSwapPair.mintTokens(amount: (WkdtUsdtSwapPair.totalSupply * liquidityPercentage) / 10000.0)

    destroy from
    return <- liquidityTokenVault
  }

  access(contract) fun removeLiquidity(from: @WkdtUsdtSwapPair.Vault): @WkdtUsdtSwapPair.TokenBundle {
    pre {
      from.balance > UFix64(0): "Empty liquidity token vault"
      from.balance < WkdtUsdtSwapPair.totalSupply: "Cannot remove all liquidity"
    }

    // shift decimal 4 places to avoid truncation error
    let liquidityPercentage = (from.balance * 10000.0) / WkdtUsdtSwapPair.totalSupply

    assert(liquidityPercentage > UFix64(0), message: "Liquidity too small")

    // Burn liquidity tokens and withdraw
    WkdtUsdtSwapPair.burnTokens(from: <- from)

    let token1Vault <- WkdtUsdtSwapPair.token1Vault.withdraw(amount: (WkdtUsdtSwapPair.token1Vault.balance * liquidityPercentage) / 10000.0) as! @WakandaToken.Vault
    let token2Vault <- WkdtUsdtSwapPair.token2Vault.withdraw(amount: (WkdtUsdtSwapPair.token2Vault.balance * liquidityPercentage) / 10000.0) as! @TeleportedTetherToken.Vault

    let tokenBundle <- WkdtUsdtSwapPair.createTokenBundle(fromToken1: <- token1Vault, fromToken2: <- token2Vault)
    return <- tokenBundle
  }

  init() {
    self.isFrozen = true // frozen until admin unfreezes
    self.totalSupply = 0.0
    self.feePercentage = 0.003 // 0.3%

    self.TokenStoragePath = /storage/wkdtUsdtFspLpVault02
    self.TokenPublicBalancePath = /public/wkdtUsdtFspLpBalance02
    self.TokenPublicReceiverPath = /public/wkdtUsdtFspLpReceiver02

    // Setup internal WakandaToken vault
    self.token1Vault <- WakandaToken.createEmptyVault() as! @WakandaToken.Vault

    // Setup internal TeleportedTetherToken vault
    self.token2Vault <- TeleportedTetherToken.createEmptyVault() as! @TeleportedTetherToken.Vault

    let admin <- create Admin()
    self.account.save(<-admin, to: /storage/wkdtUsdtPairAdmin)

    // Emit an event that shows that the contract was initialized
    emit TokensInitialized(initialSupply: self.totalSupply)
  }
}