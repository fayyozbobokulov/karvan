import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class JusticeBirthService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["birth_by_pinfl", "birth_by_cert", "birth_by_name"],
      serviceName: "egov_zags",
      category: "civil_status",
    };
  }
}
