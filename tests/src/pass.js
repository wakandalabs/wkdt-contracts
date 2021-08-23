import {getWakandaAdminAddress} from "./common";
import {deployContractByName, executeScript, mintFlow, sendTransaction} from "flow-js-testing";

export const deployPass = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");

  const addressMap = {
    NonFungibleToken: WakandaAdmin,
    WakandaToken: WakandaAdmin,
  };

  await deployContractByName({to: WakandaAdmin, name: "NonFungibleToken"})
  await deployContractByName({to: WakandaAdmin, name: "WakandaToken"})
  return deployContractByName({ to: WakandaAdmin, name: "WakandaPass", addressMap});
};

export const setupPassOnAccount = async (account) => {
  const name = "token/setupWakandaPassCollection";
  const signers = [account];
  return sendTransaction({ name, signers });
}

export const getPassSupply = async () => {
  const name = "token/getPassSupply";
  return executeScript({ name });
}

export const isPassInit = async (address) => {
  const name = "token/isPassInit";
  const args = [address];
  return executeScript({ name, args });
}

export const mintPass = async (signer, recipient, metadata) => {
  const name = "token/admin/mintWakandaPass";
  const args = [recipient, metadata];
  const signers = [signer];

  return sendTransaction({ name, args, signers });
}

export const transferPass = async (sender, recipient, itemId) => {
  const name = "token/transferPass";
  const args = [recipient, itemId];
  const signers = [sender];

  return sendTransaction({ name, args, signers });
};

export const getWakandaPass = async (account, itemID) => {
  const name = "token/getPassDetail";
  const args = [account, itemID];

  return executeScript({ name, args });
};

export const getPassList = async (account) => {
  const name = "token/getPassList";
  const args = [account];

  return executeScript({ name, args });
}

export const getPassIds = async (account) => {
  const name = "token/getPassIds";
  const args = [account];

  return executeScript({ name, args });
}
