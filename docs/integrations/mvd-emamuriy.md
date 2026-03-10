# MVD Emamuriy — `/mvd/services/emamuriy/v1/by-pinpp`

**Category:** Legal
**Service:** egov_mvd
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Checks a person's emamuriy (wanted/search) status by their PINPP. Used for background checks to determine if a person is listed in law enforcement search databases.

---

## Methods

### `emamuriy`

| Field         | Value                                |
| ------------- | ------------------------------------ |
| HTTP Method   | GET                                  |
| Endpoint      | `/mvd/services/emamuriy/v1/by-pinpp` |
| Service       | egov_mvd                             |
| Timeout       | 60000ms                              |
| Requires Auth | Yes                                  |

#### Query Params

```json
{
  "pinpp": "$pinpp",
  "user_consent": "Y",
  "request_prupose": "Checking background",
  "transaction_id": 1
}
```

#### Placeholder Variables

| Placeholder | Source                    | Description                                       |
| ----------- | ------------------------- | ------------------------------------------------- |
| `$pinpp`    | Flow context / user input | Personal Identification Number of Physical Person |

#### Response Structure

Default transform. Returns emamuriy status records for the given person.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

None.

## Postman Examples

### `emamuriy`

> Get e-mamuriy ish (administrative cases) information by PINFL.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/mvd/services/emamuriy/v1/by-pinpp?pinpp=30601811060031&user_consent=yes&request_prupose=%D0%BF%D0%BE%D0%BB%D1%83%D1%87%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85&transaction_id=0911CD8B-E4DE-41B2-A07F-BA209E6171A1' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable  | Example Value                          | Description                                      |
| ----------------- | -------------------------------------- | ------------------------------------------------ |
| `pinpp`           | `30601811060031`                       | Test PINFL                                       |
| `user_consent`    | `yes`                                  | User consent flag                                |
| `request_prupose` | `получение данных`                     | Purpose of the request (URL-encoded in the cURL) |
| `transaction_id`  | `0911CD8B-E4DE-41B2-A07F-BA209E6171A1` | Unique transaction identifier                    |

---

## Seed Data Reference

```typescript
{
  methodName: "emamuriy",
  serviceName: "egov_mvd",
  httpMethod: "GET",
  endpoint: "/mvd/services/emamuriy/v1/by-pinpp",
  defaultBody: {
    pinpp: "$pinpp",
    user_consent: "Y",
    request_prupose: "Checking background",
    transaction_id: 1
  }
}
```
