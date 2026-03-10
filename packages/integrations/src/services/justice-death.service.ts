import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class JusticeDeathService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["death_by_pinfl", "death_by_cert", "death_by_name"],
      serviceName: "egov_zags",
      category: "civil_status",
    };
  }
}
