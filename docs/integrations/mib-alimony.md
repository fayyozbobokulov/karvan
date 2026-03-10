# MIB Alimony — `/mib/service/aliment/v2/pinfl`

**Category:** Legal
**Service:** egov_mib
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Checks alimony (aliment) obligations for a person by their PINPP through the MIB (Ministry of Internal Affairs Bureau of Compulsory Enforcement) service. Used for background checks to determine if a person has active alimony obligations.

---

## Methods

### `alimony`

| Field         | Value                           |
| ------------- | ------------------------------- |
| HTTP Method   | GET                             |
| Endpoint      | `/mib/service/aliment/v2/pinfl` |
| Service       | egov_mib                        |
| Timeout       | 60000ms                         |
| Requires Auth | Yes                             |

#### Query Params

```json
{
  "pin": "$pinpp",
  "type": "1",
  "transaction_id": 1,
  "sender_pinfl": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y"
}
```

#### Placeholder Variables

| Placeholder     | Source                    | Description                                                |
| --------------- | ------------------------- | ---------------------------------------------------------- |
| `$pinpp`        | Flow context / user input | Personal Identification Number of the person being checked |
| `$sender_pinpp` | Flow context / system     | PINPP of the requesting user or system sender              |

#### Response Structure

Default transform. Returns alimony obligation records for the given person.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

None.

## Postman Examples

### `alimony`

> Получает информацию об алиментах по ПИНФЛ. Возвращает данные об исполнительных производствах, суммах.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/mib/service/aliment/v2/pinfl?pin=40608880191580&type=1&transaction_id=1&sender_pinfl=31002730280037&purpose=test&consent=Yes' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{sender_pinpp}}` | `31002730280037` | PINFL of the requesting user (sender)        |

---

## Seed Data Reference

```typescript
{
  methodName: "alimony",
  serviceName: "egov_mib",
  httpMethod: "GET",
  endpoint: "/mib/service/aliment/v2/pinfl",
  defaultBody: {
    pin: "$pinpp",
    type: "1",
    transaction_id: 1,
    sender_pinfl: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y"
  }
}
```
