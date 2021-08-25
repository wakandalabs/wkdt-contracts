import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve} from "flow-js-testing";
import {
  burnWkdt,
  deployWkdt,
  getWkdtBalance,
  getWkdtSupply,
  isWkdtInit,
  mintWkdt,
  setupWkdtOnAccount,
  transferWkdt
} from "../src/wkdt";
import {getWakandaAdminAddress, toUFix64} from "../src/common";

jest.setTimeout(10000);

describe("wkdt", ()=>{
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../");
    const port = 8080;
    const logging = false;
    
    await init(basePath, { port, logging });
    return emulator.start(port);
  });
  
  afterEach(async () => {
    return emulator.stop();
  });

  it("shall deploy wkdt", async () => {
    await shallPass(deployWkdt());
    const supply = await getWkdtSupply();
    expect(supply).toBe(toUFix64(10000000));
    const WakandaAdmin = await getWakandaAdminAddress();
    const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
    expect(WakandaAdminBalance).toBe(toUFix64(10000000));
  })

  it("shall transfer wkdt", async () => {
    await shallPass(deployWkdt());
    const WakandaAdmin = await getWakandaAdminAddress();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(WakandaAdmin);
    expect(await isWkdtInit(Alice)).toBe(false)
    await setupWkdtOnAccount(Alice);
    expect(await isWkdtInit(Alice)).toBe(true)
    await shallPass(transferWkdt(WakandaAdmin, Alice, toUFix64(1000000)));

    await shallResolve(async () => {
      const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
      expect(WakandaAdminBalance).toBe(toUFix64(9000000));
      const aliceBalance = await getWkdtBalance(Alice);
      expect(aliceBalance).toBe(toUFix64(1000000));
      const supply = await getWkdtSupply();
      expect(supply).toBe(toUFix64(10000000));
    });
  });

  it('should mint wkdt', async () => {
    await shallPass(deployWkdt());
    const WakandaAdmin = await getWakandaAdminAddress();
    await setupWkdtOnAccount(WakandaAdmin);
    const supply = await getWkdtSupply();
    expect(supply).toBe(toUFix64(10000000))
    await mintWkdt(WakandaAdmin, WakandaAdmin, toUFix64(100))
    const newsupply = await getWkdtSupply();
    expect(newsupply).toBe(toUFix64(10000100))
  });

  it('should burn wkdt', async () => {
    await shallPass(deployWkdt());
    const WakandaAdmin = await getWakandaAdminAddress();
    await setupWkdtOnAccount(WakandaAdmin);
    const supply = await getWkdtSupply();
    expect(supply).toBe(toUFix64(10000000))
    await burnWkdt(WakandaAdmin, toUFix64(1))
    const newsupply = await getWkdtSupply();
    expect(newsupply).toBe(toUFix64(9999999))
  });
})
