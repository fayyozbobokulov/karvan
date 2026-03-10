import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class AdliyaFamilyCheckService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["family_check"],
      serviceName: "egov_main",
      category: "civil_status",
    };
  }
}
