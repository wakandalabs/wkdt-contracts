import {deployContractByName, executeScript, mintFlow, sendTransaction} from "flow-js-testing";
import { getWakandaAdminAddress } from "./common";

export const deployWkdt = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");

  return deployContractByName({ to: WakandaAdmin, name: "WakandaToken" });
};

export const setupWkdtOnAccount = async (account) => {
  const name = "token/setupWkdt";
  const signers = [account];

  return sendTransaction({ name, signers });
};

export const getWkdtBalance = async (account) => {
  const name = "token/getWkdtBalance";
  const args = [account];

  return executeScript({ name, args });
};

export const isWkdtInit = async (address) => {
  const name = "token/isWkdtInit";
  const args = [address];
  return executeScript({ name, args });
}

export const getWkdtSupply = async () => {
  const name = "token/getWkdtSupply";
  return executeScript({ name });
};

export const transferWkdt = async (sender, recipient, amount) => {
  const name = "token/transferWkdt";
  const args = [amount, recipient];
  const signers = [sender];

  return sendTransaction({ name, args, signers });
};

export const mintWkdt = async (signer, recipient, amount) => {
  const name = "token/mintWkdt";
  const args = [recipient, amount];
  const signers = [signer];

  return sendTransaction({ name, args, signers })
}