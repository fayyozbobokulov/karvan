# YHXBB Driver License -- /yhxbb/driverlicense/by-pinfl/v1

**Category:** transport
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves driver license information by PINFL from the YHXBB (road police) system. The response is transformed into a structured object containing person details, license information, categories, address, and birth place.

---

## Methods

### `driver_license`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/yhxbb/driverlicense/by-pinfl/v1` |
| Service       | egov_main                          |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "pRequestID": 1,
  "applicantPinpp": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the driver being looked up |

#### Custom Transform

When `ModelPerson` is present in the response, the data is merged and restructured into the following format:

```json
{
  "person": "ModelPerson",
  "license": "ModelDL",
  "categories": "ModelDLCategory",
  "address": "driverAddress",
  "birthPlace": "driverBirthPlace"
}
```

| Output Field | Source Field       | Description                                  |
| ------------ | ------------------ | -------------------------------------------- |
| `person`     | `ModelPerson`      | Personal information of the driver           |
| `license`    | `ModelDL`          | Driver license details                       |
| `categories` | `ModelDLCategory`  | License category information (A, B, C, etc.) |
| `address`    | `driverAddress`    | Registered address of the driver             |
| `birthPlace` | `driverBirthPlace` | Birth place of the driver                    |

---

## Postman Examples

### `driver_license`

> Get driver license information by PINFL.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/yhxbb/driverlicense/by-pinfl/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pRequestID": "123",
    "applicantPinpp": "{{pnfl}}"
  }'
```

| Postman Variable   | Example Value    | Description                                          |
| ------------------ | ---------------- | ---------------------------------------------------- |
| `{{pnfl}}`         | `52103046570025` | Test PINFL (14-digit personal identification number) |
| `{{access_token}}` | _(from OAuth)_   | Bearer token for API authorization                   |

---

## Seed Data Reference

```typescript
{
  methodName: "driver_license",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/yhxbb/driverlicense/by-pinfl/v1",
  defaultBody: {
    pRequestID: 1,
    applicantPinpp: "$pinpp"
  }
}
```
