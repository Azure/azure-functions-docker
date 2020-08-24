import { AxiosResponse } from "axios";
import chalk from "chalk";

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