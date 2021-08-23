import {getWakandaAdminAddress} from "./common";
import {deployContractByName, executeScript, mintFlow, sendTransaction} from "flow-js-testing";

export const deployProfile = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");
  return deployContractByName({to: WakandaAdmin, name: "WakandaProfile"})
};

export const getProfile = async ( address ) => {
  const name = "profile/getWakandaProfile";
  const args = [address];
  return executeScript({ name, args });
}

export const getMultiProfile = async ( addresses ) => {
  const name = "profile/getMultiWakandaProfile";
  const args = [addresses];
  return executeScript({ name, args });
}

export const setupProfileOnAccount = async (account) => {
  const name = "profile/setupWakandaProfile";
  const signers = [account];
  return sendTransaction({ name, signers });
}

export const updateProfile = async (address, title, avatar, color, bio, website, email) => {
  const name = "profile/updateWakandaProfile";
  const args = [title, avatar, color, bio, website, email];
  const signers = [address];

  return sendTransaction({name, args, signers})

}