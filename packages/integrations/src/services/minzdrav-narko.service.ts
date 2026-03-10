import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MinzdravNarkoService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "narko_by_pinfl",
        "narko_by_passport",
        "narko_by_cert",
      ],
      serviceName: "egov_minzdrav",
      category: "medical",
    };
  }
}
