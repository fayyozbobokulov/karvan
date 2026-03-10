import { BaseIntegrationService } from "../core/base-integration.service.js";
import { getByPath } from "../core/utils.js";
import type {
  IntegrationServiceMeta,
  IntegrationResponse,
  IntegrationError,
} from "../core/types.js";

interface PassportNormalizedData {
  surname: string | null;
  firstname: string | null;
  patronymic: string | null;
  birthDate: string | null;
  gender: string | null;
  nationality: string | null;
  birthPlace: string | null;
  documentNumber: string | null;
  expiryDate: string | null;
  issueDate: string | null;
  pinfl: string | null;
}

export class GcpDocrestService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["passport_by_pinfl_document", "passport_data"],
      serviceName: "egov_main",
      category: "passport",
    };
  }

  protected override transformResponse(
    _methodName: string,
    rawData: Record<string, unknown>,
  ): IntegrationResponse {
    const dataArray = rawData["Data"] as Record<string, unknown>[] | undefined;
    const entry = dataArray?.[0];

    if (!entry) {
      return {
        success: false,
        code: null,
        message: "No data returned",
        data: null,
        raw: rawData,
      };
    }

    const docs = entry["documents"] as Record<string, unknown>[] | undefined;
    const firstDoc = docs?.[0];

    const normalized: PassportNormalizedData = {
      surname: (entry["surnamelat"] as string) ?? null,
      firstname: (entry["namelat"] as string) ?? null,
      patronymic: (entry["patronymlat"] as string) ?? null,
      birthDate: (entry["birth_date"] as string) ?? null,
      gender: (entry["sex"] as string) ?? null,
      nationality: (entry["nationality"] as string) ?? null,
      birthPlace: (entry["birthplace"] as string) ?? null,
      documentNumber: (entry["current_document"] as string) ?? null,
      expiryDate: (firstDoc?.["dateend"] as string) ?? null,
      issueDate: (firstDoc?.["datebegin"] as string) ?? null,
      pinfl: (entry["current_pinpp"] as string) ?? null,
    };

    return {
      success: rawData["result"] === 1,
      code: (rawData["result"] as number) ?? null,
      message: "",
      data: normalized as unknown as Record<string, unknown>,
      raw: rawData,
    };
  }

  protected override detectServiceError(
    _methodName: string,
    rawData: Record<string, unknown>,
    _transformed: IntegrationResponse,
  ): IntegrationError | null {
    const comments = (rawData["comments"] as string) ?? "";
    const errorCode = String(rawData["result"] ?? "");

    if (errorCode === "303001") {
      return {
        status: "not_found",
        message: "Person not found (303001)",
        code: "303001",
      };
    }

    const lower = comments.toLowerCase();
    if (lower.includes("ne nayden") || lower.includes("topilmadi")) {
      return { status: "not_found", message: comments, code: null };
    }

    return null;
  }
}
