import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MvdEmamuriyService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["emamuriy"],
      serviceName: "egov_mvd",
      category: "legal",
    };
  }
}
