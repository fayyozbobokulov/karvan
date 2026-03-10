import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class GnkSelfemployedService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["self_employed"],
      serviceName: "egov_gnk",
      category: "tax",
    };
  }
}
