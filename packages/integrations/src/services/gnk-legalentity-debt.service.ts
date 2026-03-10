import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class GnkLegalentityDebtService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["legal_entity_debt"],
      serviceName: "egov_gnk",
      category: "tax",
    };
  }
}
