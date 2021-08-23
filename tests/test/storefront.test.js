import path from "path";
import {emulator, getAccountAddress, init, shallPass} from "flow-js-testing";
import {
  cleanStoreItem,
  deployStorefront,
  getSaleOffer,
  getSaleOfferIds,
  removeStoreItem,
  salePassWkdt,
  setupStorefront
} from "../src/storefront";
import {mintPass, setupPassOnAccount} from "../src/pass";


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
    await shallPass(mintPass(Alice, Alice, {}))
    await shallPass(salePassWkdt(Alice, 0, 100.0))
    await shallResolve(async () => {
      const itemIds = await getPassIds(Alice);
      const supply = await getPassSupply();
      expect(itemIds.length).toBe(1);
      expect(supply).toBe(1)
    });
    const saleOfferIds = await getSaleOfferIds(Alice);
    console.log(saleOfferIds);
  });

  it('shall get sale offer', async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    await shallPass(salePassWkdt(Alice, 0, 100))
    const saleOfferIds = await getSaleOfferIds(Alice);
    const saleOffer = await getSaleOffer(Alice, saleOfferIds[0])
    console.log(saleOffer)
  });

  it("shall remove sale offer", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    await shallPass(salePassWkdt(Alice, 0, 10))
    const saleOfferIds = await getSaleOfferIds(Alice);
    console.log(saleOfferIds)
    await shallPass(removeStoreItem(Alice,saleOfferIds[0]))
    const newsaleOfferIds = await getSaleOfferIds(Alice);
    console.log(newsaleOfferIds)
  });

  it("shall clean store item", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    await shallPass(salePassWkdt(Alice, 0, 100))
    const saleOfferIds = await getSaleOfferIds(Alice);
    console.log(saleOfferIds)
    await shallPass(cleanStoreItem(Alice,saleOfferIds[0]))
    const newsaleOfferIds = await getSaleOfferIds(Alice);
    console.log(newsaleOfferIds)
  });

  it("shall remove store item", async () => {
    await shallPass(deployStorefront());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupStorefront(Alice));
    await shallPass(setupPassOnAccount(Alice));
    await shallPass(mintPass(Alice, Alice, {}))
    await shallPass(salePassWkdt(Alice, 0, 100))
    const saleOfferIds = await getSaleOfferIds(Alice);
    console.log(saleOfferIds)
    await shallPass(removeStoreItem(Alice,saleOfferIds[0]))
    const newsaleOfferIds = await getSaleOfferIds(Alice);
    console.log(newsaleOfferIds)
  });
})
