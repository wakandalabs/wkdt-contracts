import { getAccountAddress } from "flow-js-testing";

const UFIX64_PRECISION = 8;

// UFix64 values shall be always passed as strings
export const toUFix64 = (value) => value.toFixed(UFIX64_PRECISION);
export const toUInt64 = (value) => value.toFixed(0)

export const getWakandaAdminAddress = async () => getAccountAddress("WakandaAdmin");
