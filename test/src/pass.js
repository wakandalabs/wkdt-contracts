import {getWakandaAdminAddress} from "./common";
import {deployContractByName, mintFlow} from "flow-js-testing";

export const deployPass = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");

  const addressMap = {
    NonFungibleToken: WakandaAdmin,
    WakandaTokenStaking: WakandaAdmin,
    WakandaToken: WakandaAdmin,
    WakandaPassStamp: WakandaAdmin
  };

  await deployContractByName({to: WakandaAdmin, name: "NonFungibleToken"})
  await deployContractByName({to: WakandaAdmin, name: "WakandaToken"})
  await deployContractByName({to: WakandaAdmin, name: "WakandaTokenStaking", addressMap})
  await deployContractByName({to: WakandaAdmin, name: "WakandaPassStamp", addressMap})
  return deployContractByName({ to: WakandaAdmin, name: "WakandaPass", addressMap});
};
