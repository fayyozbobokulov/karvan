# Justice Migration Info — `/justice/service/migrant/v1`

**Category:** Legal
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Retrieves migration information for a person through the Justice service. Checks a person's migration status and history using their PINPP and TIN. Used for background checks to determine migration-related records.

---

## Methods

### `migration_info`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | POST                          |
| Endpoint      | `/justice/service/migrant/v1` |
| Service       | egov_main                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

#### Request Body

```json
{
  "transaction_id": 1,
  "sender_pin": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y",
  "tin": "$tin",
  "pinfl": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder     | Source                    | Description                                                |
| --------------- | ------------------------- | ---------------------------------------------------------- |
| `$sender_pinpp` | Flow context / system     | PINPP of the requesting user or system sender              |
| `$tin`          | Flow context / user input | Taxpayer Identification Number (TIN/INN)                   |
| `$pinpp`        | Flow context / user input | Personal Identification Number of the person being checked |

#### Response Structure

Default transform. Returns migration records and status for the given person.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

None.

## Postman Examples

### `migration_info`

> Получает информацию о миграционных данных и составе семьи по ПИНФЛ и ИНН.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/migrant/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "transaction_id": "1",
    "sender_pin": "31002730280037",
    "purpose": "test",
    "consent": "yes",
    "tin": "123456789",
    "pinfl": "31002730280037"
  }'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{sender_pinpp}}` | `31002730280037` | PINFL of the requesting user (sender)        |
| `{{tin}}`          | `123456789`      | Taxpayer Identification Number (INN)         |
| `{{pnfl}}`         | `31002730280037` | PINFL of the person being checked            |

---

## Seed Data Reference

```typescript
{
  methodName: "migration_info",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/justice/service/migrant/v1",
  defaultBody: {
    transaction_id: 1,
    sender_pin: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y",
    tin: "$tin",
    pinfl: "$pinpp"
  }
}
```
