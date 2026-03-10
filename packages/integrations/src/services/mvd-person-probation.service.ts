import { BaseIntegrationService } from "../core/base-integration.service.js";
import { getByPath } from "../core/utils.js";
import type {
  IntegrationServiceMeta,
  IntegrationRequest,
} from "../core/types.js";

export class MvdPersonProbationService extends BaseIntegrationService {
  getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: [
        "person_probation_request",
        "person_probation_response",
      ],
      serviceName: "egov_mvd",
      category: "legal",
    };
  }

  protected override buildRequestBody(
    request: IntegrationRequest,
  ): Record<string, unknown> {
    if (
      request.methodName === "person_probation_response" &&
      request.parentResponse
    ) {
      const pId = getByPath(request.parentResponse, "pId");
      const pDate = getByPath(request.parentResponse, "pDate");
      if (pId !== undefined) {
        return { pId, pDate: pDate ?? null };
      }
    }

    return super.buildRequestBody(request);
  }
}
