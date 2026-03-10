import { BaseIntegrationService } from "../core/base-integration.service.js";
import type {
  IntegrationServiceMeta,
  IntegrationResponse,
  IntegrationError,
} from "../core/types.js";

export class YhxbbCarinfoService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "vehicle_by_pinfl",
        "vehicle_by_plate",
        "vehicle_by_tin",
        "vehicle_by_tech_passport",
      ],
      serviceName: "egov_main",
      category: "transport",
    };
  }

  protected override detectServiceError(
    _methodName: string,
    rawData: Record<string, unknown>,
    transformed: IntegrationResponse,
  ): IntegrationError | null {
    const errorCode = rawData["error_code"] as string | undefined;

    if (
      errorCode === "VEHICLE_NOT_REGISTERED" ||
      errorCode === "NO_DATA_FOUND"
    ) {
      return {
        status: "not_found",
        message: `Vehicle not found: ${errorCode}`,
        code: errorCode,
      };
    }

    if (Array.isArray(transformed.data) && transformed.data.length === 0) {
      return { status: "not_found", message: "No vehicles found", code: null };
    }

    return null;
  }
}
