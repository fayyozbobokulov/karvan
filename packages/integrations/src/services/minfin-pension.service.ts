import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MinfinPensionService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "pension_check",
        "pension_size",
        "pension_assign_and_amount",
      ],
      serviceName: "egov_main",
      category: "finance",
    };
  }
}
