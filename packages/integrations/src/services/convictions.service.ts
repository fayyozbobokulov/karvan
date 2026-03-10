import { BaseIntegrationService } from "../core/base-integration.service.js";
import { getByPath } from "../core/utils.js";
import type {
  IntegrationServiceMeta,
  IntegrationRequest,
} from "../core/types.js";

export class ConvictionsService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["conviction_search", "conviction_check"],
      serviceName: "egov_main",
      category: "legal",
    };
  }

  protected override buildRequestBody(
    request: IntegrationRequest,
  ): Record<string, unknown> {
    if (request.methodName === "conviction_check" && request.parentResponse) {
      const idQuery = getByPath(request.parentResponse, "id_query");
      if (idQuery !== undefined) {
        return { id_query: idQuery };
      }
    }

    return super.buildRequestBody(request);
  }
}
