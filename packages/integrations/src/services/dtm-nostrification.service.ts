import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class DtmNostrificationService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["nostrification"],
      serviceName: "egov_main",
      category: "education",
    };
  }
}
