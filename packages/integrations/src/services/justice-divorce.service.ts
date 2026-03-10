import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class JusticeDivorceService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "divorce_by_pinfl",
        "divorce_by_cert",
        "divorce_by_name",
      ],
      serviceName: "egov_zags",
      category: "civil_status",
    };
  }
}
