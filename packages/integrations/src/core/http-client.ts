import axios, { type AxiosRequestConfig } from "axios";
import type { HttpMethod, PollingConfig } from "./types.js";
import { getByPath } from "./utils.js";

export interface HttpRequestOptions {
  method: HttpMethod;
  url: string;
  headers: Record<string, string>;
  data?: Record<string, unknown>;
  params?: Record<string, unknown>;
  timeout: number;
  pollingConfig?: PollingConfig;
}

export class HttpClient {
  async request(options: HttpRequestOptions): Promise<Record<string, unknown>> {
    const axiosConfig: AxiosRequestConfig = {
      method: options.method,
      url: options.url,
      headers: options.headers,
      timeout: options.timeout,
      ...(options.data ? { data: options.data } : {}),
      ...(options.params ? { params: options.params } : {}),
    };

    let response = await axios(axiosConfig);

    if (options.pollingConfig) {
      const { intervalMs, maxAttempts, successCondition } =
        options.pollingConfig;
      for (let attempt = 0; attempt < maxAttempts; attempt++) {
        if (successCondition) {
          const conditionMet = getByPath(
            response.data as Record<string, unknown>,
            successCondition,
          );
          if (conditionMet) break;
        } else {
          break;
        }
        await new Promise((resolve) => setTimeout(resolve, intervalMs));
        response = await axios(axiosConfig);
      }
    }

    return response.data as Record<string, unknown>;
  }
}
