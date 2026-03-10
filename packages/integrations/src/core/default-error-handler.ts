import axios from "axios";
import type { IntegrationError, IntegrationErrorStatus } from "./types.js";

export class DefaultErrorHandler {
  classify(error: unknown): IntegrationError {
    let status: IntegrationErrorStatus = "api_failure";
    let message = "Unknown error";
    let code: string | null = null;

    if (error instanceof Error) {
      message = error.message;
    }

    if (axios.isAxiosError(error)) {
      if (error.response) {
        const statusCode = error.response.status;
        if (statusCode === 401 || statusCode === 403) {
          status = "unauthorized";
        } else if (statusCode === 404) {
          status = "not_found";
        } else {
          status = "api_failure";
        }
        code = String(statusCode);
        const responseData = error.response.data as
          | Record<string, unknown>
          | undefined;
        message =
          (responseData?.["message"] as string) ||
          error.response.statusText ||
          message;
      } else if (error.code === "ECONNABORTED") {
        status = "timeout";
      }
    }

    return { status, message, code };
  }
}
