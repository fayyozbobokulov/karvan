import { BaseIntegrationService } from "../core/base-integration.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

export class LabourServicesService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["unemployment", "work_history"],
      serviceName: "egov_main",
      category: "employment",
    };
  }
}
