# MVD Address Info — `/mvd/services/address/info/pin/v1`

**Category:** Address
**Service:** egov_mvd
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Retrieves address information for a person by their PINPP (Personal Identification Number of Physical Person). Returns structured address records including region, district, street, and other location details.

---

## Methods

### `address_info`

| Field         | Value                               |
| ------------- | ----------------------------------- |
| HTTP Method   | POST                                |
| Endpoint      | `/mvd/services/address/info/pin/v1` |
| Service       | egov_mvd                            |
| Timeout       | 60000ms                             |
| Requires Auth | Yes                                 |

#### Request Body

```json
{
  "pinpp": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                    | Description                                       |
| ----------- | ------------------------- | ------------------------------------------------- |
| `$pinpp`    | Flow context / user input | Personal Identification Number of Physical Person |

#### Response Structure

Default transform. The API returns address records with fields such as:

- Region
- District
- Street
- House number
- Apartment number
- Registration date
- Additional address metadata

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

None.

## Postman Examples

### `address_info`

> Fetches certificate data for the provided PNFL using the Bearer token.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/mvd/services/address/info/pin/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "pinpp": "32712792580011"
}'
```

| Postman Variable | Example Value    | Description                                |
| ---------------- | ---------------- | ------------------------------------------ |
| —                | `32712792580011` | Test PINPP value used directly in the body |

---

## Seed Data Reference

```typescript
{
  methodName: "address_info",
  serviceName: "egov_mvd",
  httpMethod: "POST",
  endpoint: "/mvd/services/address/info/pin/v1",
  defaultBody: {
    pinpp: "$pinpp"
  }
}
```
