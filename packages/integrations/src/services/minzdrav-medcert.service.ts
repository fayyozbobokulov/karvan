import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MinzdravMedcertService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["medical_certificate"],
      serviceName: "egov_minzdrav",
      category: "medical",
    };
  }
}
