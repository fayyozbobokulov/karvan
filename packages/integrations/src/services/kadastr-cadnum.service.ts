import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class KadastrCadnumService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "property_by_pinfl",
        "property_by_tin",
        "property_by_cadastral",
      ],
      serviceName: "egov_kadastr",
      category: "property",
    };
  }
}
