import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class YhxbbDriverlicenseService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["driver_license"],
      serviceName: "egov_main",
      category: "transport",
    };
  }
}
