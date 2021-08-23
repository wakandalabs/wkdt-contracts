import path from "path";

import { emulator, init, getAccountAddress, shallPass, shallResolve, shallRevert } from "flow-js-testing";

import { toUFix64, getWakandaAdminAddress } from "../src/common";
import {
  deployWkdt,
  setupWkdtOnAccount,
  getWkdtBalance,
  getWkdtSupply,
  mintWkdt,
  transferWkdt,
} from "../src/wkdt";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(500000);

describe("Wkdt", () => {
  // Instantiate emulator and path to Cadence files
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../../");
    const port = 7001;
    init(basePath, port);
    return emulator.start(port, false);
  });

  // Stop emulator, so it could be restarted
  afterEach(async () => {
    return emulator.stop();
  });

  it("shall have initialized supply field correctly", async () => {
    // Deploy contract
    await shallPass(deployWkdt());

    await shallResolve(async () => {
      const supply = await getWkdtSupply();
      expect(supply).toBe(toUFix64(0));
    });
  });

  it("shall be able to create empty Vault that doesn't affect supply", async () => {
    // Setup
    await deployWkdt();
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupWkdtOnAccount(Alice));

    await shallResolve(async () => {
      const supply = await getWkdtSupply();
      const aliceBalance = await getWkdtBalance(Alice);
      expect(supply).toBe(toUFix64(0));
      expect(aliceBalance).toBe(toUFix64(0));
    });
  });

  it("shall not be able to mint zero tokens", async () => {
    // Setup
    await deployWkdt();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(Alice);

    // Mint instruction with amount equal to 0 shall be reverted
    await shallRevert(mintWkdt(Alice, toUFix64(0)));
  });

  it("shall mint tokens, deposit, and update balance and total supply", async () => {
    // Setup
    await deployWkdt();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(Alice);
    const amount = toUFix64(50);

    // Mint Wkdt tokens for Alice
    await shallPass(mintWkdt(Alice, amount));

    // Check Wkdt total supply and Alice's balance
    await shallResolve(async () => {
      // Check Alice balance to equal amount
      const balance = await getWkdtBalance(Alice);
      expect(balance).toBe(amount);

      // Check Wkdt supply to equal amount
      const supply = await getWkdtSupply();
      expect(supply).toBe(amount);
    });
  });

  it("shall not be able to withdraw more than the balance of the Vault", async () => {
    // Setup
    await deployWkdt();
    const WakandaAdmin = await getWakandaAdminAddress();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(WakandaAdmin);
    await setupWkdtOnAccount(Alice);

    // Set amounts
    const amount = toUFix64(1000);
    const overflowAmount = toUFix64(30000);

    // Mint instruction shall resolve
    await shallResolve(mintWkdt(WakandaAdmin, amount));

    // Transaction shall revert
    await shallRevert(transferWkdt(WakandaAdmin, Alice, overflowAmount));

    // Balances shall be intact
    await shallResolve(async () => {
      const aliceBalance = await getWkdtBalance(Alice);
      expect(aliceBalance).toBe(toUFix64(0));

      const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
      expect(WakandaAdminBalance).toBe(amount);
    });
  });

  it("shall be able to withdraw and deposit tokens from a Vault", async () => {
    await deployWkdt();
    const WakandaAdmin = await getWakandaAdminAddress();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(WakandaAdmin);
    await setupWkdtOnAccount(Alice);
    await mintWkdt(WakandaAdmin, toUFix64(1000));

    await shallPass(transferWkdt(WakandaAdmin, Alice, toUFix64(300)));

    await shallResolve(async () => {
      // Balances shall be updated
      const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
      expect(WakandaAdminBalance).toBe(toUFix64(700));

      const aliceBalance = await getWkdtBalance(Alice);
      expect(aliceBalance).toBe(toUFix64(300));

      const supply = await getWkdtSupply();
      expect(supply).toBe(toUFix64(1000));
    });
  });
});
