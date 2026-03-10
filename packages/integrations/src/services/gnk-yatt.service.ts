import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class GnkYattService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["yatt_entrepreneur_data", "yatt_founders_data"],
      serviceName: "egov_gnk",
      category: "tax",
    };
  }
}
