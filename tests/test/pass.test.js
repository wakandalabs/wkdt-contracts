import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve, shallRevert} from "flow-js-testing";
import {
  deployPass,
  getPassIds,
  getPassSupply,
  getWakandaPass, isPassInit,
  mintPass,
  setupPassOnAccount,
  transferPass
} from "../src/pass";

jest.setTimeout(10000);

describe("pass", () => {
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../");
    const port = 8080;
    const logging = false;

    await init(basePath, {port, logging});
    return emulator.start(port);
  });

  afterEach(async () => {
    return emulator.stop();
  });

  it("shall deploy pass and 0 pass", async () => {
    await shallPass(deployPass());
    const supply = await getPassSupply();
    expect(supply).toBe(0)
  })

  it('shall be able to mint a pass', async () => {
    await shallPass(deployPass());
    const Alice = await getAccountAddress("Alice");
    expect(await isPassInit(Alice)).toBe(false)
    await shallPass(setupPassOnAccount(Alice));
    expect(await isPassInit(Alice)).toBe(true)
    await shallPass(mintPass(Alice, Alice, {"title": "jest"}));
    await shallResolve(async () => {
      const itemIds = await getPassIds(Alice);
      const supply = await getPassSupply();
      expect(itemIds.length).toBe(1);
      expect(supply).toBe(1)
    });
  });

  it('shall be able get detail of pass', async () => {
    await shallPass(deployPass());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupPassOnAccount(Alice));

    await shallPass(mintPass(Alice, Alice, {"title": "jest"}));
    await shallResolve(async () => {
      const pass = await getWakandaPass(Alice, 0);
      expect(pass.id).toBe(0)
      expect(pass.owner).toBe(Alice)
      expect(pass.metadata["title"]).toBe("jest")
    })
  });

  it("shall be able to create a new empty NFT Collection", async () => {
    await shallPass(deployPass());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupPassOnAccount(Alice));

    await shallResolve(async () => {
      const itemIds = await getPassIds(Alice);
      expect(itemIds.length).toBe(0);
    });
  });

  it("shall not be able to withdraw an NFT that doesn't exist in a collection", async () => {
    await shallPass(deployPass());
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupPassOnAccount(Bob));
    await shallRevert(transferPass(Alice, Bob, 1337));
  });

  it("shall be able to withdraw an NFT and deposit to another accounts collection", async () => {
    await shallPass(deployPass());
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupPassOnAccount(Bob));
    await shallPass(mintPass(Alice, Alice, {}));
    await shallPass(transferPass(Alice, Bob, 0));
    expect((await getPassIds(Alice)).length).toBe(0);
    expect((await getPassIds(Bob)).length).toBe(1);
  });

})
