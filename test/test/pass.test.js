import path from "path";
import { emulator, init } from "flow-js-testing";

jest.setTimeout(10000);

describe("pass", ()=>{
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../cadence"); 
    const port = 8080;
    const logging = false;
    
    await init(basePath, { port, logging });
    return emulator.start(port);
  });
  
  afterEach(async () => {
    return emulator.stop();
  });
  
  test("deployPass", async ()     => {
    // WRITE YOUR ASSERTS HERE
  })


})
