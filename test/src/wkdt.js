import { deployContractByName, executeScript, mintFlow, sendTransaction } from "flow-js-testing";
import { getWakandaAdminAddress } from "./common";

/*
 * Deploys Wkdt contract to WakandaAdmin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployWkdt = async () => {
  const WakandaAdmin = await getWakandaAdminAddress();
  await mintFlow(WakandaAdmin, "10.0");

  return deployContractByName({ to: WakandaAdmin, name: "Wkdt" });
};

/*
 * Setups Wkdt Vault on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupWkdtOnAccount = async (account) => {
  const name = "wkdt/setup_account";
  const signers = [account];

  return sendTransaction({ name, signers });
};

/*
 * Returns Wkdt balance for **account**.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UFix64}
 * */
export const getWkdtBalance = async (account) => {
  const name = "wkdt/get_balance";
  const args = [account];

  return executeScript({ name, args });
};

/*
 * Returns Wkdt supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UFix64}
 * */
export const getWkdtSupply = async () => {
  const name = "wkdt/get_supply";
  return executeScript({ name });
};

/*
 * Mints **amount** of Wkdt tokens and transfers them to recipient.
 * @param {string} recipient - recipient address
 * @param {string} amount - UFix64 amount to mint
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const mintWkdt = async (recipient, amount) => {
  const WakandaAdmin = await getWakandaAdminAddress();

  const name = "wkdt/mint_tokens";
  const args = [recipient, amount];
  const signers = [WakandaAdmin];

  return sendTransaction({ name, args, signers });
};

/*
 * Transfers **amount** of Wkdt tokens from **sender** account to **recipient**.
 * @param {string} sender - sender address
 * @param {string} recipient - recipient address
 * @param {string} amount - UFix64 amount to transfer
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const transferWkdt = async (sender, recipient, amount) => {
  const name = "wkdt/transfer_tokens";
  const args = [amount, recipient];
  const signers = [sender];

  return sendTransaction({ name, args, signers });
};
