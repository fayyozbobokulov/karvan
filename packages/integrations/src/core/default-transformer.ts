import type { IntegrationResponse } from "./types.js";

export class DefaultTransformer {
  transform(rawData: Record<string, unknown>): IntegrationResponse {
    const success = this.detectSuccess(rawData);
    const code = this.extractCode(rawData);
    const message = this.extractMessage(rawData);
    const data = this.extractData(rawData);

    return { success, code, message, data, raw: rawData };
  }

  private detectSuccess(raw: Record<string, unknown>): boolean {
    if (raw["success"] === true) return true;
    if (raw["result_code"] === 1) return true;
    if (raw["AnswereId"] === 1) return true;
    if (raw["pResult"] === 1) return true;
    if (raw["status"] === 1) return true;

    const statusObj = raw["status"];
    if (
      statusObj &&
      typeof statusObj === "object" &&
      (statusObj as Record<string, unknown>)["code"] === 200
    ) {
      return true;
    }

    if (raw["result"] === 1) return true;
    if (raw["Data"] !== undefined) return true;
    if (raw["data"] !== undefined) return true;

    return false;
  }

  private extractCode(raw: Record<string, unknown>): number | null {
    if (typeof raw["result_code"] === "number") return raw["result_code"];
    if (typeof raw["AnswereId"] === "number") return raw["AnswereId"];
    if (typeof raw["pResult"] === "number") return raw["pResult"];
    if (typeof raw["result"] === "number") return raw["result"];

    const statusObj = raw["status"];
    if (statusObj && typeof statusObj === "object") {
      const code = (statusObj as Record<string, unknown>)["code"];
      if (typeof code === "number") return code;
    }

    if (typeof raw["status"] === "number") return raw["status"];

    return null;
  }

  private extractMessage(raw: Record<string, unknown>): string {
    if (typeof raw["message"] === "string") return raw["message"];
    if (typeof raw["comments"] === "string") return raw["comments"];
    if (typeof raw["error_message"] === "string") return raw["error_message"];

    const statusObj = raw["status"];
    if (statusObj && typeof statusObj === "object") {
      const msg = (statusObj as Record<string, unknown>)["message"];
      if (typeof msg === "string") return msg;
    }

    return "";
  }

  private extractData(
    raw: Record<string, unknown>,
  ): Record<string, unknown> | unknown[] | null {
    if (Array.isArray(raw["items"])) return raw["items"];
    if (raw["data"] != null) return raw["data"] as Record<string, unknown>;
    if (raw["Data"] != null) return raw["Data"] as Record<string, unknown>;
    if (Array.isArray(raw["results"])) return raw["results"];

    const result = raw["result"];
    if (result && typeof result === "object" && !Array.isArray(result)) {
      const resultObj = result as Record<string, unknown>;
      if (resultObj["data"] != null) {
        return resultObj["data"] as Record<string, unknown>;
      }
      return resultObj;
    }

    return raw;
  }
}
