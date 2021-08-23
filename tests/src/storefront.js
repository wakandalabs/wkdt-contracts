import {getWakandaAdminAddress} from "./common";
import {deployContractByName, executeScript, mintFlow, sendTransaction} from "flow-js-testing";
import * as types from "@onflow/types";

export const deployStorefront = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");

  const addressMap = {
    NonFungibleToken: WakandaAdmin,
    WakandaPass: WakandaAdmin,
    WakandaToken: WakandaAdmin
  };

  await deployContractByName({to: WakandaAdmin, name: "NonFungibleToken"})
  await deployContractByName({to: WakandaAdmin, name: "WakandaToken"})
  await deployContractByName({to: WakandaAdmin, name: "WakandaPass", addressMap})

  return deployContractByName({to: WakandaAdmin, name: "WakandaStorefront", addressMap})

};

export const getSaleOffer = async ( address, saleOfferResourceID ) => {
  const name = "token/getSaleOffer";
  const args = [address, saleOfferResourceID];
  return executeScript({ name, args });
}

export const getSaleOfferIds = async (address) => {
  const name = "token/getSaleOfferIds";
  const args = [address];
  return executeScript({ name, args });
}

export const getSaleOfferItem = async ( addresses, saleOfferResourceID ) => {
  const name = "token/getMultiWakandaProfile";
  const args = [addresses, saleOfferResourceID];
  return executeScript({ name, args });
}

export const setupStorefront = async (account) => {
  const name = "token/setupWakandaStorefront";
  const signers = [account];
  return sendTransaction({ name, signers });
}

export const salePassWkdt = async (address, salePassID, salePassPrice) => {
  const name = "token/salePassWkdt";
  const args = [0, 100];
  const signers = [address];

  return sendTransaction({name, args, signers})
}

export const cleanStoreItem = async (address, saleOfferResourceID) => {
  const name = "token/cleanSaleOffer";
  const args = [address, saleOfferResourceID];
  const signers = [address];

  return sendTransaction({name, args, signers})
}

export const removeStoreItem = async (address, saleOfferResourceID) => {
  const name = "token/removeSaleOffer";
  const args = [saleOfferResourceID];
  const signers = [address];

  return sendTransaction({name, args, signers})
}