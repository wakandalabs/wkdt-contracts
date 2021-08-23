import path from "path";
import {emulator, init, shallPass} from "flow-js-testing";
import {deployPass} from "../src/pass";

jest.setTimeout(10000);

describe("pass", ()=>{
  beforeEach(async () => {
    const basePath = path.resolve(__dirname,  "../../");
    const port = 8080;
    const logging = false;
    
    await init(basePath, { port, logging });
    return emulator.start(port);
  });
  
  afterEach(async () => {
    return emulator.stop();
  });
  
  test("deployPass", async ()     => {
    await shallPass(deployPass());
  })


})
