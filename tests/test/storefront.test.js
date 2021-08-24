import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve, shallRevert} from "flow-js-testing";
import {
  buyPass,
  cleanStoreItem,
  deployStorefront,
  getSaleOffer,
  getSaleOfferIds, getSaleOfferItem,
  removeStoreItem,
  salePassWkdt,
  setupStorefront
} from "../src/storefront";
import {getPassIds, mintPass, setupPassOnAccount} from "../src/pass";
import {getWakandaAdminAddress, toUFix64, toUInt64} from "../src/common";
import {getWkdtBalance, setupWkdtOnAccount, transferWkdt} from "../src/wkdt";


jest.setTimeout(10000);

describe("storefront", () => {
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

  it("shall deploy storefront", async () => {
    await shallPass(deployStorefront());
  })

  it('should setup on account', async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
  });

  it("shall sale pass wkdt and get ids", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupWkdtOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    const passID = 0
    await shallPass(salePassWkdt(Alice, passID, toUFix64(100.0)))
    await shallResolve(getSaleOfferIds(Alice));
  });

  it('shall get sale offer', async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupWkdtOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    const saleResult = await shallPass(salePassWkdt(Alice, 0, toUFix64(100)))
    const saleEvent = saleResult.events[0]
    const saleOfferId = saleEvent.data.saleOfferResourceID
    await shallResolve(getSaleOfferItem(Alice, saleOfferId))
  });

  it('should buy sale pass', async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupWkdtOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    const saleResult = await shallPass(salePassWkdt(Alice, 0, toUFix64(100)))
    const saleEvent = saleResult.events[0]
    const saleOfferId = saleEvent.data.saleOfferResourceID
    await shallResolve(getSaleOfferItem(Alice, saleOfferId));
    const WakandaAdmin = await getWakandaAdminAddress()
    const Bob = await getAccountAddress("Bob")
    await shallPass(setupWkdtOnAccount(Bob));
    await shallPass(setupPassOnAccount(Bob));
    await shallPass(setupStorefront(Bob));
    await transferWkdt(WakandaAdmin, Bob, toUFix64(10000));
    expect(await getWkdtBalance(Bob)).toBe(toUFix64(10000));
    await shallPass(buyPass(Bob, saleOfferId, Alice));
    expect((await getSaleOfferIds(Alice)).length).toBe(0);
    expect((await getPassIds(Bob)).length).toBe(1);
    expect((await getPassIds(Alice)).length).toBe(0);
  });

  it("shall remove sale offer", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupWkdtOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    const saleResult = await shallPass(salePassWkdt(Alice, 0, toUFix64(100)))
    const saleEvent = saleResult.events[0]
    const saleOfferId = saleEvent.data.saleOfferResourceID
    await shallPass(removeStoreItem(Alice, saleOfferId))
    expect((await getSaleOfferIds(Alice)).length).toBe(0)
  });

  it("shall remove store item", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(setupWkdtOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    const saleResult = await shallPass(salePassWkdt(Alice, 0, toUFix64(100)))
    const saleEvent = saleResult.events[0]
    const saleOfferId = saleEvent.data.saleOfferResourceID
    await shallPass(removeStoreItem(Alice, saleOfferId))
    const offerIds = await getSaleOfferIds(Alice);
    expect(offerIds.length).toBe(0)
  });
})
