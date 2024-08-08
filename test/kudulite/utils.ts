import { AxiosResponse } from "axios";
import CryptoJS from "crypto-js";
import chalk from "chalk";
import { IContainerStartContext } from "./interfaces";

export const timeout = (ms: number) => new Promise(res => setTimeout(res, ms));

export const retry = async (
  axiosFunc: () => Promise<AxiosResponse<any>>,
  interval: number = 5_000,
  count: number = 5,
): Promise<AxiosResponse<any>> => {
  let trials = 0;
  let error = false;
  do {
    try {
      const response = await axiosFunc();
      const method = (response.config.method as string).toUpperCase();
      const url = response.config.url;
      const status = response.status;
      console.log(chalk.green(`[${method}] ${url} => ${status}`));
      error = false;
      return Promise.resolve<AxiosResponse<any>>(response);
    } catch (e) {
      console.error(chalk.red(e));
      error = true;
      if (trials >= count) {
        throw e;
      } else {
        await timeout(interval);
        trials++;
      }
    }
  } while (true);
};

export const encryptContext = (encryptionKey: CryptoJS.lib.WordArray, plainText: string) => {
  const plainTextUtf8Bytes = CryptoJS.enc.Utf8.parse(plainText);
  const aesEncrypted = CryptoJS.AES.encrypt(plainTextUtf8Bytes, encryptionKey, {
    iv: CryptoJS.enc.Utf8.parse('0123456789abcdef')
  });
  const aesIvBase64 = CryptoJS.enc.Base64.stringify(aesEncrypted.iv);
  const aesEncryptedMessageBase64 = CryptoJS.enc.Base64.stringify(aesEncrypted.ciphertext);
  const aesKeySHA256Base64 = CryptoJS.SHA256(aesEncrypted.key as unknown as string).toString(CryptoJS.enc.Base64);

  return `${aesIvBase64}.${aesEncryptedMessageBase64}.${aesKeySHA256Base64}`;
};

export const toCSharpTick = (datetime: Date): number => {
  return datetime.getTime() * 10000 + 621355680000000000;
}

// WEBSITE_AUTH_ENCRYPTION_KEY x-ms-site-restricted-token
export const getSiteRestrictedTokenFromHex = (authEncryptionKey: string) => {
  const current = new Date();
  const expiry = new Date(current.getFullYear(), current.getMonth(), current.getDate() + 2);
  const encryptionKey = CryptoJS.enc.Hex.parse(authEncryptionKey);
  return encryptContext(encryptionKey, `exp=${toCSharpTick(expiry)}`);
};

// CONTAINER_ENCRYPTION_KEY x-ms-site-restricted-token
export const getSiteRestirctedTokenFromBase64 = (containerKey: string) => {
  const current = new Date();
  const expiry = new Date(current.getFullYear(), current.getMonth(), current.getDate() + 2);
  const encryptionKey = CryptoJS.enc.Base64.parse(containerKey);
  return encryptContext(encryptionKey, `exp=${toCSharpTick(expiry)}`);
};

// CONTAINER_ENCRYPTION_KEY /admin/instance/assign
export const getEncryptedContextFromBase64 = (containerKey: string, context: IContainerStartContext) => {
  const containerKeyBytes = CryptoJS.enc.Base64.parse(containerKey);
  const result = encryptContext(containerKeyBytes, JSON.stringify(context));
  return result;
};
