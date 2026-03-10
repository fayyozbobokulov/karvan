import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class GnkIndentreDebtService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["entrepreneur_debt"],
      serviceName: "egov_gnk",
      category: "tax",
    };
  }
}
