import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class JusticeMarriageService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "marriage_by_pinfl",
        "marriage_by_cert",
        "marriage_by_name",
      ],
      serviceName: "egov_zags",
      category: "civil_status",
    };
  }
}
