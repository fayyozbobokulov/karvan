import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class IhmaPovertyRegistryService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["poverty_registry"],
      serviceName: "egov_main",
      category: "social",
    };
  }
}
