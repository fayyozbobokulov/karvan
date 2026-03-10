# Adliya Family Check — /adliya/family-chek/v1

**Category:** civil_status
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Provides family membership lookup through the Adliya (Ministry of Justice) system. Returns a list of family members associated with a given individual, including their PINFL, full name, and relationship type. This endpoint uses the `egov_main` service rather than `egov_zags`.

---

## Methods

### `family_check`

| Field         | Value                    |
| ------------- | ------------------------ |
| HTTP Method   | POST                     |
| Endpoint      | `/adliya/family-chek/v1` |
| Service       | egov_main                |
| Timeout       | 60000ms                  |
| Requires Auth | Yes                      |

#### Request Body

```json
{
  "transaction_id": 1,
  "sender_pin": "$sender_pinpp",
  "pinfl": "$pinpp",
  "tin": "$tin"
}
```

#### Placeholder Variables

| Placeholder     | Source           | Description                                                            |
| --------------- | ---------------- | ---------------------------------------------------------------------- |
| `$sender_pinpp` | Workflow context | PINFL of the requesting/sender entity                                  |
| `$pinpp`        | Workflow context | Personal identification number (PINFL) of the individual to look up    |
| `$tin`          | Workflow context | Taxpayer Identification Number (TIN) of the organization or individual |

#### Response Structure

The raw response contains nested data. A custom transform is applied to extract the family members list.

**Custom Transform:**

Extracts `data.data?.members` from the response, returning an array of family member objects:

```typescript
interface FamilyMember {
  pinfl: string; // PINFL of the family member
  full_name: string; // Full name of the family member
  relative_type: string; // Relationship type (e.g., spouse, child, parent)
}
```

**Transformed Response Example:**

```json
[
  {
    "pinfl": "12345678901234",
    "full_name": "Ivanov Ivan Ivanovich",
    "relative_type": "spouse"
  },
  {
    "pinfl": "12345678901235",
    "full_name": "Ivanova Maria Ivanovna",
    "relative_type": "child"
  }
]
```

---

## Postman Examples

### `family_check`

> Checks family member relationships for given PINFLs.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/adliya/family-chek/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "transaction_id": "12312",
  "sender_pin": "31002730280037",
  "pinfl": ["61505016520061"],
  "tin": "123456789"
}'
```

| Postman Variable   | Example Value    | Description                    |
| ------------------ | ---------------- | ------------------------------ |
| `{{sender_pinpp}}` | `31002730280037` | Sender PINFL                   |
| `{{tin}}`          | `123456789`      | Taxpayer Identification Number |

---

## Seed Data Reference

```typescript
{
  methodName: "family_check",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/adliya/family-chek/v1",
  defaultBody: {
    transaction_id: 1,
    sender_pin: "$sender_pinpp",
    pinfl: "$pinpp",
    tin: "$tin"
  }
}
```
