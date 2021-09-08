import {getWakandaAdminAddress} from "./common";
import {deployContractByName, executeScript, mintFlow, sendTransaction} from "flow-js-testing";

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

  return deployContractByName({to: WakandaAdmin, name: "NFTStorefront", addressMap})

};

export const getListing = async ( address, listingResourceID ) => {
  const name = "token/getListing";
  const args = [address, listingResourceID];
  return executeScript({ name, args });
}

export const getListingIds = async (address) => {
  const name = "token/getListingIds";
  const args = [address];
  return executeScript({ name, args });
}

export const getListingItem = async ( addresses, listingResourceID ) => {
  const name = "token/getListingItem";
  const args = [addresses, listingResourceID];
  return executeScript({ name, args });
}

export const setupStorefront = async (account) => {
  const name = "token/setupNFTStorefront";
  const signers = [account];
  return sendTransaction({ name, signers });
}

export const salePassWkdt = async (address, salePassID, salePassPrice) => {
  const name = "token/salePassWkdt";
  const args = [salePassID, salePassPrice];
  const signers = [address];

  return sendTransaction({name, args, signers})
}

export const buyPass = async (buyer, resourceId, seller) => {
  const name = "token/buyPassWkdt";
  const args = [resourceId, seller];
  const signers = [buyer];

  return sendTransaction({ name, args, signers });
};

export const cleanStoreItem = async (admin, listingResourceID) => {
  const name = "token/cleanListing";
  const args = [listingResourceID];
  const signers = [admin];

  return sendTransaction({name, args, signers})
}

export const removeStoreItem = async (address, listingResourceID) => {
  const name = "token/removeListing";
  const args = [listingResourceID];
  const signers = [address];

  return sendTransaction({name, args, signers})
}