# Convictions — `/convictions/search/v2` and `/conviction/check/v2`

**Category:** Legal
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Two-step conviction check process. The first method searches for conviction records using personal identification data, and the second method checks detailed conviction status using the query ID returned from the search step.

---

## Methods

### `conviction_search`

| Field         | Value                    |
| ------------- | ------------------------ |
| HTTP Method   | POST                     |
| Endpoint      | `/convictions/search/v2` |
| Service       | egov_main                |
| Timeout       | 60000ms                  |
| Requires Auth | Yes                      |

#### Request Body

```json
{
  "firstname": null,
  "lastname": null,
  "birth_year": "$birth_year",
  "pinfl": "$pinpp",
  "middlename": null,
  "comments": "Checking background",
  "passport": "$passport_series$passport_number",
  "organization_id": 1,
  "region_id": 1,
  "consent": "Y",
  "is_allowed_abroad": "N"
}
```

#### Placeholder Variables

| Placeholder        | Source                    | Description                                                 |
| ------------------ | ------------------------- | ----------------------------------------------------------- |
| `$birth_year`      | Flow context / user input | Year of birth (e.g., "1990")                                |
| `$pinpp`           | Flow context / user input | Personal Identification Number of Physical Person           |
| `$passport_series` | Flow context / user input | Passport series (e.g., "AA")                                |
| `$passport_number` | Flow context / user input | Passport number (e.g., "1234567"), concatenated with series |

#### Response Structure

Default transform. Returns conviction search results including a query ID (`id_query`) used for the subsequent check step.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

### `conviction_check`

| Field         | Value                  |
| ------------- | ---------------------- |
| HTTP Method   | POST                   |
| Endpoint      | `/conviction/check/v2` |
| Service       | egov_main              |
| Timeout       | 60000ms                |
| Requires Auth | Yes                    |

#### Request Body

```json
{
  "id_query": null
}
```

#### Placeholder Variables

| Placeholder | Source                                | Description                                       |
| ----------- | ------------------------------------- | ------------------------------------------------- |
| `id_query`  | Parent response (`conviction_search`) | Query ID returned from the conviction search step |

#### Response Structure

Default transform. Returns detailed conviction check results for the given query.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

`conviction_check` depends on `conviction_search`.

The chaining works as follows:

1. `conviction_search` is called first with the person's identification and passport data.
2. The response provides an `id_query` value.
3. This value is passed as `parent_id` context into `conviction_check`.
4. `conviction_check` uses the `id_query` from the parent response to retrieve detailed conviction results.

## Postman Examples

### `conviction_search`

> Отправляет запрос на поиск судимости. Возвращает request_id для следующего шага.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/convictions/search/v2' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "firstname": "IVAN",
    "lastname": "YEDELKIN",
    "birth_year": 1973,
    "pinfl": "31002730280037",
    "middlename": "ANATOLEVICH",
    "comments": "test",
    "passport": "AB8069344"
  }'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |

### `conviction_check`

> Получает результат проверки судимости по id_query (request_id), полученному на первом шаге.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/conviction/check/v2' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "id_query": 1599958
  }'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |

---

## Seed Data Reference

```typescript
// Step 1: Search
{
  methodName: "conviction_search",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/convictions/search/v2",
  defaultBody: {
    firstname: null,
    lastname: null,
    birth_year: "$birth_year",
    pinfl: "$pinpp",
    middlename: null,
    comments: "Checking background",
    passport: "$passport_series$passport_number",
    organization_id: 1,
    region_id: 1,
    consent: "Y",
    is_allowed_abroad: "N"
  }
}

// Step 2: Check (parent_id -> conviction_search)
{
  methodName: "conviction_check",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/conviction/check/v2",
  defaultBody: {
    id_query: null
  }
}
```
