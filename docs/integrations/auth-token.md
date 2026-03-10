# OAuth2 Token — `https://iskm.egov.uz:9444/oauth2/token`

**Category:** Authentication
**Service:** All eGov services
**Token URL:** `https://iskm.egov.uz:9444/oauth2/token` (env: `EGOV_TOKEN_URL`)

## Overview

All eGov API calls require a Bearer token obtained via the OAuth2 Resource Owner Password Credentials (password grant) flow. The token is acquired using a consumer key/secret pair (Basic auth) combined with a username/password. Tokens have a limited lifetime and must be refreshed before expiry.

In our system, token management is handled automatically by the `getOrRefreshEgovToken` activity, which caches tokens in the `egov_tokens` database table with a 5-minute expiry buffer.

---

## Authentication Flow

1. **Client credentials** (`EGOV_CONSUMER_KEY` + `EGOV_CONSUMER_SECRET`) are Base64-encoded for Basic auth
2. **User credentials** (`EGOV_USERNAME` + `EGOV_PASSWORD`) are sent as form-urlencoded body
3. The token server returns `access_token`, `expires_in`, and `token_type`
4. The `access_token` is used as a Bearer token in all subsequent API calls

---

## Request

| Field        | Value                                        |
| ------------ | -------------------------------------------- |
| HTTP Method  | POST                                         |
| URL          | `https://iskm.egov.uz:9444/oauth2/token`     |
| Content-Type | `application/x-www-form-urlencoded`          |
| Auth Header  | `Basic base64(consumer_key:consumer_secret)` |

### Request Body (form-urlencoded)

| Parameter    | Value      | Description                           |
| ------------ | ---------- | ------------------------------------- |
| `grant_type` | `password` | OAuth2 grant type (always "password") |
| `username`   | env var    | eGov API username (`EGOV_USERNAME`)   |
| `password`   | env var    | eGov API password (`EGOV_PASSWORD`)   |

### Response

```json
{
  "access_token": "eyJ4NXQiOiJNell...",
  "scope": "default",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

| Field          | Type   | Description                                |
| -------------- | ------ | ------------------------------------------ |
| `access_token` | string | Bearer token for API calls                 |
| `token_type`   | string | Always `"Bearer"`                          |
| `expires_in`   | number | Token lifetime in seconds (typically 3600) |
| `scope`        | string | Token scope (typically `"default"`)        |

---

## Environment Variables

| Variable               | Description                     |
| ---------------------- | ------------------------------- |
| `EGOV_TOKEN_URL`       | Token endpoint URL              |
| `EGOV_CONSUMER_KEY`    | OAuth2 client ID (consumer key) |
| `EGOV_CONSUMER_SECRET` | OAuth2 client secret            |
| `EGOV_USERNAME`        | Resource owner username         |
| `EGOV_PASSWORD`        | Resource owner password         |

---

## Token Caching (Workflow Engine)

The `getOrRefreshEgovToken` activity in `token.activities.ts` handles token lifecycle:

- **Cache check:** Looks up an active token for the given `serviceName` in `egov_tokens` table
- **Expiry buffer:** Considers a token expired if it has less than **5 minutes** remaining
- **Refresh:** If expired or missing, fetches a new token, deactivates the old one, and stores the new one
- **Per-service:** Each eGov service (`egov_main`, `egov_mvd`, `egov_mib`, etc.) can have its own token

---

## Postman Example

> Gets an access_token using Basic auth (consumer key/secret) and password grant (iip_username/iip_password).

```bash
curl -X POST 'https://iskm.egov.uz:9444/oauth2/token' \
  -H 'Authorization: Basic base64(CONSUMER_KEY:CONSUMER_SECRET)' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=password&username=YOUR_USERNAME&password=YOUR_PASSWORD'
```

| Postman Variable      | Description            |
| --------------------- | ---------------------- |
| `{{consumer_key}}`    | OAuth2 consumer key    |
| `{{consumer_secret}}` | OAuth2 consumer secret |
| `{{iip_username}}`    | eGov API username      |
| `{{iip_password}}`    | eGov API password      |

---

## Usage in API Calls

After obtaining the token, include it in all eGov API requests:

```
Authorization: Bearer <access_token>
```

Every child workflow in the integration execution system calls `getOrRefreshEgovToken` before making API requests, ensuring fresh tokens even for long-running batch operations.
