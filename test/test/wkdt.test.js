import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve, shallRevert} from "flow-js-testing";
import {deployWkdt, getWkdtBalance, getWkdtSupply, mintWkdt, setupWkdtOnAccount, transferWkdt} from "../src/wkdt";
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
  
 // Stop emulator, so it could be restarted
  afterEach(async () => {
    return emulator.stop();
  });

  // 部署合约，初始发行量 700 万
  it("deploy WakandaToken", async () => {
    await deployWkdt();
    const supply = await getWkdtSupply();
    expect(supply).toBe(toUFix64(7000000));
  })

  // 查询账户余额
  it("fetch WakandaToken Balance", async () => {
    const WakandaAdmin = await getWakandaAdminAddress();
    const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
    console.log(WakandaAdminBalance)
  })

  it("shall be able to withdraw and deposit tokens from a Vault", async () => {
    // await deployWkdt();
    const WakandaAdmin = await getWakandaAdminAddress();
    const Alice = await getAccountAddress("Alice");
    await setupWkdtOnAccount(WakandaAdmin);
    await setupWkdtOnAccount(Alice);
    await shallPass(transferWkdt(WakandaAdmin, Alice, toUFix64(300)));

    await shallResolve(async () => {
      // Balances shall be updated
      const WakandaAdminBalance = await getWkdtBalance(WakandaAdmin);
      // expect(WakandaAdminBalance).toBe(toUFix64(700));

      const aliceBalance = await getWkdtBalance(Alice);
      expect(aliceBalance).toBe(toUFix64(300));

      const supply = await getWkdtSupply();
      expect(supply).toBe(toUFix64(7000000));
    });
  });



})
