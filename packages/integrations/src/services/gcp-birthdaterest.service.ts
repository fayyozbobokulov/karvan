import { GcpDocrestService } from "./gcp-docrest.service.js";
import type { IntegrationServiceMeta } from "../core/types.js";

/** Same transform and error handling as GcpDocrest — different endpoint. */
export class GcpBirthdaterestService extends GcpDocrestService {
  override getMeta(): IntegrationServiceMeta {
    return {
      supportedMethods: ["passport_by_document_birthdate"],
      serviceName: "egov_main",
      category: "passport",
    };
  }
}
