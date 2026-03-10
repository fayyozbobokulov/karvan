import { HttpClient } from "./http-client.js";
import { DefaultTransformer } from "./default-transformer.js";
import { DefaultErrorHandler } from "./default-error-handler.js";
import { replacePlaceholders, getByPath } from "./utils.js";
import type {
  IntegrationRequest,
  IntegrationCallResult,
  IntegrationResponse,
  IntegrationError,
  IntegrationServiceMeta,
  HttpMethod,
} from "./types.js";

export abstract class BaseIntegrationService {
  protected httpClient: HttpClient;
  protected defaultTransformer: DefaultTransformer;
  protected defaultErrorHandler: DefaultErrorHandler;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
    this.defaultTransformer = new DefaultTransformer();
    this.defaultErrorHandler = new DefaultErrorHandler();
  }

  /** Subclass must declare its supported methods, service name, and category. */
  abstract getMeta(): IntegrationServiceMeta;

  /**
   * Template Method — the invariant execution skeleton.
   * Subclasses override individual steps, not this method.
   */
  async execute(request: IntegrationRequest): Promise<IntegrationCallResult> {
    const validationError = this.validateRequest(request);
    if (validationError) {
      return { status: "params_missing", error: validationError };
    }

    const body = this.buildRequestBody(request);
    const headers = this.buildHeaders(request);
    const url = this.buildUrl(request);
    const method = request.setting.httpMethod.toLowerCase() as HttpMethod;

    try {
      const rawResponse = await this.httpClient.request({
        method,
        url,
        headers,
        data: method !== "get" ? body : undefined,
        params: method === "get" ? body : undefined,
        timeout: request.setting.timeout,
        pollingConfig: request.setting.pollingConfig ?? undefined,
      });

      const transformed = this.transformResponse(
        request.methodName,
        rawResponse,
      );

      const serviceError = this.detectServiceError(
        request.methodName,
        rawResponse,
        transformed,
      );
      if (serviceError) {
        return {
          status: serviceError.status,
          error: serviceError,
          rawHttpData: rawResponse,
        };
      }

      return {
        status: "success",
        response: transformed,
        rawHttpData: rawResponse,
      };
    } catch (error: unknown) {
      const classified = this.handleError(request.methodName, error);
      return { status: classified.status, error: classified };
    }
  }

  // ── Overridable hooks ────────────────────────────────────────────

  protected validateRequest(
    _request: IntegrationRequest,
  ): IntegrationError | null {
    return null;
  }

  protected buildRequestBody(
    request: IntegrationRequest,
  ): Record<string, unknown> {
    let body = (
      request.setting.defaultBody
        ? replacePlaceholders(
            request.setting.defaultBody,
            request.searchCriteria,
          )
        : {}
    ) as Record<string, unknown>;

    if (request.parentResponse && request.setting.responseMapping) {
      for (const [targetField, sourcePath] of Object.entries(
        request.setting.responseMapping,
      )) {
        const value = getByPath(request.parentResponse, sourcePath);
        if (value !== undefined) {
          body[targetField] = value;
        }
      }
    }

    return body;
  }

  protected buildHeaders(request: IntegrationRequest): Record<string, string> {
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
      ...((request.setting.defaultHeaders as Record<string, string>) || {}),
    };

    if (request.setting.requiresAuth && request.token) {
      headers["Authorization"] =
        `${request.token.tokenType} ${request.token.accessToken}`;
    }

    return headers;
  }

  protected buildUrl(request: IntegrationRequest): string {
    const baseUrl =
      request.setting.baseUrl || process.env["EGOV_API_BASE_URL"] || "";
    return `${baseUrl}${request.setting.endpoint}`;
  }

  protected transformResponse(
    _methodName: string,
    rawData: Record<string, unknown>,
  ): IntegrationResponse {
    return this.defaultTransformer.transform(rawData);
  }

  protected detectServiceError(
    _methodName: string,
    _rawData: Record<string, unknown>,
    _transformed: IntegrationResponse,
  ): IntegrationError | null {
    return null;
  }

  protected handleError(_methodName: string, error: unknown): IntegrationError {
    return this.defaultErrorHandler.classify(error);
  }
}
