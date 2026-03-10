import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MinzdravVtekService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["vtek_by_passport", "vtek_by_birth_doc"],
      serviceName: "egov_minzdrav",
      category: "medical",
    };
  }
}
