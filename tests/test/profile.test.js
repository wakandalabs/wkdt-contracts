import path from "path";
import {emulator, getAccountAddress, init, shallPass, shallResolve} from "flow-js-testing";
import {deployProfile, getProfile, isProfileInit, setupProfileOnAccount, updateProfile} from "../src/profile";

jest.setTimeout(10000);

describe("profile", () => {
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

  it("shall deploy profile", async () => {
    await shallPass(deployProfile());
  })

  it('should setup profile', async () => {
    await shallPass(deployProfile());
    const Alice = await getAccountAddress("Alice");
    expect(await isProfileInit(Alice)).toBe(false)
    await shallPass(setupProfileOnAccount(Alice));
    expect(await isProfileInit(Alice)).toBe(true)
    await shallResolve(getProfile(Alice))
  });

  it('should update profile', async () => {
    await shallPass(deployProfile());
    const Alice = await getAccountAddress("Alice");
    await shallPass(setupProfileOnAccount(Alice));
    await shallResolve(getProfile(Alice))
    await shallPass(updateProfile(Alice, "name", "", "", "", "", ""))
    const newProfile = await getProfile(Alice)
    expect(newProfile.name).toBe("name")
  });
})
