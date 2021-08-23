import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve, shallRevert} from "flow-js-testing";
import {deployWkdt, getWkdtBalance, getWkdtSupply, setupWkdtOnAccount, transferWkdt} from "../src/wkdt";
import {getWakandaAdminAddress, toUFix64} from "../src/common";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

describe("wkdt", ()=>{
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../");
		// You can specify different port to parallelize execution of describe blocks
    const port = 8080; 
		// Setting logging flag to true will pipe emulator output to console
    const logging = false;
    
    await init(basePath, { port, logging });
    return emulator.start(port);
  });
  
  afterEach(async () => {
    return emulator.stop();
  });

  it("deploy wkdt", async () => {
    await deployWkdt();
    const supply = await getWkdtSupply();
    expect(supply).toBe(toUFix64(7000000));
    const WakandaAdmin = await getWakandaAdminAddress();
    const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
    expect(WakandaAdminBalance).toBe(toUFix64(7000000));
  })

  it("transfer wkdt", async () => {
    await deployWkdt();
    const WakandaAdmin = await getWakandaAdminAddress();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(WakandaAdmin);
    await setupWkdtOnAccount(Alice);
    await shallPass(transferWkdt(WakandaAdmin, Alice, toUFix64(1000000)));

    await shallResolve(async () => {
      const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
      expect(WakandaAdminBalance).toBe(toUFix64(6000000));

      const aliceBalance = await getWkdtBalance(Alice);
      expect(aliceBalance).toBe(toUFix64(1000000));

      const supply = await getWkdtSupply();
      expect(supply).toBe(toUFix64(7000000));
    });
  });
})
