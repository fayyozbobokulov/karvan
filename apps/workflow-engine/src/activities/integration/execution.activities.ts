import { eq } from 'drizzle-orm';
import axios from 'axios';
import {
  integrations,
  type PollingConfig,
  type IntegrationStatus,
} from '@workflow/database';
import {
  IntegrationFactory,
  type IntegrationRequest,
  type IntegrationSettingConfig,
} from '@workflow/integrations';
import { getDb } from './db';
import { getByPath, replacePlaceholders } from './helpers';

type HttpMethod = 'get' | 'post' | 'put' | 'delete' | 'patch';

export interface IntegrationSettingParam {
  methodName: string;
  httpMethod: string;
  endpoint: string;
  baseUrl?: string | null;
  defaultBody?: Record<string, unknown> | null;
  defaultHeaders?: Record<string, unknown> | null;
  timeout: number;
  requiresAuth: boolean;
  pollingConfig?: PollingConfig | null;
  responseMapping?: Record<string, string> | null;
}

// Singleton factory per worker process
let factory: IntegrationFactory | null = null;

function getFactory(): IntegrationFactory {
  if (!factory) {
    factory = new IntegrationFactory();
  }
  return factory;
}

export async function createIntegrationRecord(input: {
  requestId: string;
  integrationSettingId: string;
  methodName: string;
  pinpp?: string;
  searchCriteria?: Record<string, unknown>;
  requestBody?: Record<string, unknown>;
}): Promise<string> {
  const database = getDb();

  const [row] = await database
    .insert(integrations)
    .values({
      requestId: input.requestId,
      integrationSettingId: input.integrationSettingId,
      methodName: input.methodName,
      status: 'pending',
      pinpp: input.pinpp || null,
      searchCriteria: input.searchCriteria || null,
      requestBody: input.requestBody || null,
    })
    .returning();

  return row.id;
}

export async function executeIntegrationCall(input: {
  integrationId: string;
  setting: IntegrationSettingParam;
  searchCriteria: Record<string, unknown>;
  parentResponse?: Record<string, unknown>;
  token?: { accessToken: string; tokenType: string };
}): Promise<{
  integrationId: string;
  status: string;
  rawData?: Record<string, unknown>;
  errorMessage?: string;
}> {
  const database = getDb();
  const { setting, searchCriteria, parentResponse, token } = input;

  const registry = getFactory().getRegistry();
  const service = registry.resolve(setting.methodName);

  await database
    .update(integrations)
    .set({ status: 'running', updatedAt: new Date() })
    .where(eq(integrations.id, input.integrationId));

  // Delegate to OOP service class if registered
  if (service) {
    const request: IntegrationRequest = {
      methodName: setting.methodName,
      searchCriteria,
      parentResponse,
      token,
      setting: setting as IntegrationSettingConfig,
    };

    const result = await service.execute(request);

    if (result.status === 'success') {
      await database
        .update(integrations)
        .set({
          status: 'success',
          rawData: result.rawHttpData,
          updatedAt: new Date(),
        })
        .where(eq(integrations.id, input.integrationId));

      return {
        integrationId: input.integrationId,
        status: 'success',
        rawData: result.rawHttpData,
      };
    }

    await database
      .update(integrations)
      .set({
        status: result.status as IntegrationStatus,
        errorMessage: result.error?.message,
        errorCode: result.error?.code,
        updatedAt: new Date(),
      })
      .where(eq(integrations.id, input.integrationId));

    return {
      integrationId: input.integrationId,
      status: result.status,
      errorMessage: result.error?.message,
    };
  }

  // Legacy fallback for unregistered methods
  return legacyExecute(input, database);
}

// ── Legacy inline execution (fallback) ────────────────────────────────────

async function legacyExecute(
  input: {
    integrationId: string;
    setting: IntegrationSettingParam;
    searchCriteria: Record<string, unknown>;
    parentResponse?: Record<string, unknown>;
    token?: { accessToken: string; tokenType: string };
  },
  database: ReturnType<typeof getDb>,
): Promise<{
  integrationId: string;
  status: string;
  rawData?: Record<string, unknown>;
  errorMessage?: string;
}> {
  const { setting, searchCriteria, parentResponse, token } = input;

  try {
    let requestBody = (
      setting.defaultBody
        ? replacePlaceholders(setting.defaultBody, searchCriteria)
        : {}
    ) as Record<string, unknown>;

    if (parentResponse && setting.responseMapping) {
      for (const [targetField, sourcePath] of Object.entries(
        setting.responseMapping,
      )) {
        const value = getByPath(
          parentResponse as Record<string, unknown>,
          sourcePath,
        );
        if (value !== undefined) {
          requestBody[targetField] = value;
        }
      }
    }

    const baseUrl = setting.baseUrl || process.env.EGOV_API_BASE_URL || '';
    const url = `${baseUrl}${setting.endpoint}`;

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...((setting.defaultHeaders as Record<string, string>) || {}),
    };

    if (setting.requiresAuth && token) {
      headers['Authorization'] = `${token.tokenType} ${token.accessToken}`;
    }

    const method = setting.httpMethod.toLowerCase() as HttpMethod;
    const axiosConfig = {
      method,
      url,
      headers,
      timeout: setting.timeout,
      ...(method !== 'get' ? { data: requestBody } : { params: requestBody }),
    };

    let response = await axios(axiosConfig);

    if (setting.pollingConfig) {
      const { intervalMs, maxAttempts, successCondition } =
        setting.pollingConfig;

      for (let attempt = 0; attempt < maxAttempts; attempt++) {
        if (successCondition) {
          const conditionMet = getByPath(
            response.data as Record<string, unknown>,
            successCondition,
          );
          if (conditionMet) break;
        } else {
          break;
        }

        await new Promise((resolve) => setTimeout(resolve, intervalMs));
        response = await axios(axiosConfig);
      }
    }

    await database
      .update(integrations)
      .set({
        status: 'success',
        rawData: response.data,
        requestBody,
        updatedAt: new Date(),
      })
      .where(eq(integrations.id, input.integrationId));

    return {
      integrationId: input.integrationId,
      status: 'success',
      rawData: response.data,
    };
  } catch (error: unknown) {
    let status: IntegrationStatus = 'api_failure';
    let errorMessage = 'Unknown error';
    let errorCode: string | null = null;

    if (error instanceof Error) {
      errorMessage = error.message;
    }

    if (axios.isAxiosError(error)) {
      if (error.response) {
        const statusCode = error.response.status;
        if (statusCode === 401 || statusCode === 403) {
          status = 'unauthorized';
        } else if (statusCode === 404) {
          status = 'not_found';
        } else {
          status = 'api_failure';
        }
        errorCode = String(statusCode);
        const responseData = error.response.data as
          | Record<string, unknown>
          | undefined;
        errorMessage =
          (responseData?.message as string) ||
          error.response.statusText ||
          errorMessage;
      } else if (error.code === 'ECONNABORTED') {
        status = 'timeout';
      }
    }

    await database
      .update(integrations)
      .set({
        status,
        errorMessage,
        errorCode,
        updatedAt: new Date(),
      })
      .where(eq(integrations.id, input.integrationId));

    return {
      integrationId: input.integrationId,
      status,
      errorMessage,
    };
  }
}
