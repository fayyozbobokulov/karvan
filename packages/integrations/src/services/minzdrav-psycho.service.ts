import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MinzdravPsychoService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "psycho_by_pinfl",
        "psycho_by_passport",
        "psycho_by_cert",
      ],
      serviceName: "egov_minzdrav",
      category: "medical",
    };
  }
}
