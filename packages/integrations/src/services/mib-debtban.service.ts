import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class MibDebtbanService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "travel_ban_by_pinfl",
        "travel_ban_by_passport",
        "travel_ban_by_tin",
      ],
      serviceName: "egov_mib",
      category: "legal",
    };
  }
}
