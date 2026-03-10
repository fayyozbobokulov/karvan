import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class SsvMedkartaService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["medkarta_service"],
      serviceName: "egov_minzdrav",
      category: "medical",
    };
  }
}
