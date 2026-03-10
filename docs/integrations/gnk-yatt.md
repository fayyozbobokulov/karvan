# GNK YATT -- /gnk/service/yatt/v1/

**Category:** tax
**Service:** egov_gnk
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint group provides data from the YATT (Yagona Attestatsiya va Tasnif) system under the State Tax Committee (GNK). It includes methods for retrieving entrepreneur data and founders data, both requiring consent and sender identification.

---

## Methods

### `yatt_entrepreneur_data`

| Field         | Value                                    |
| ------------- | ---------------------------------------- |
| HTTP Method   | POST                                     |
| Endpoint      | `/gnk/service/yatt/v1/enterprenuer-data` |
| Service       | egov_gnk                                 |
| Timeout       | 60000ms                                  |
| Requires Auth | Yes                                      |

#### Request Body

```json
{
  "consent": "Y",
  "pinfl": "$pinpp",
  "purpose": "Checking background",
  "senderPin": "$sender_pinpp",
  "transactionId": 1
}
```

#### Placeholder Variables

| Placeholder     | Source                       | Description                                  |
| --------------- | ---------------------------- | -------------------------------------------- |
| `$pinpp`        | search_criteria.pinpp        | 14-digit PINFL of the person being looked up |
| `$sender_pinpp` | search_criteria.sender_pinpp | PINFL of the requesting sender               |

---

### `yatt_founders_data`

| Field         | Value                                |
| ------------- | ------------------------------------ |
| HTTP Method   | POST                                 |
| Endpoint      | `/gnk/service/yatt/v1/founders-data` |
| Service       | egov_gnk                             |
| Timeout       | 60000ms                              |
| Requires Auth | Yes                                  |

#### Request Body

```json
{
  "consent": "Y",
  "pinfl": "$pinpp",
  "purpose": "Checking background",
  "senderPin": "$sender_pinpp",
  "transactionId": 1
}
```

#### Placeholder Variables

| Placeholder     | Source                       | Description                                  |
| --------------- | ---------------------------- | -------------------------------------------- |
| `$pinpp`        | search_criteria.pinpp        | 14-digit PINFL of the person being looked up |
| `$sender_pinpp` | search_criteria.sender_pinpp | PINFL of the requesting sender               |

---

## Postman Examples

### `yatt_entrepreneur_data`

> Получает информацию о предпринимателе (YaTT) по PINFL, включая регистрационные данные, тип деятельности.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gnk/service/yatt/v1/enterprenuer-data' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "consent": "yes",
    "pinfl": "{{pnfl}}",
    "purpose": "test",
    "senderPin": "{{pnfl}}",
    "transactionId": "1"
  }'
```

### `yatt_founders_data`

> Получает информацию об учредителях и акционерах предпринимательского субъекта по PINFL.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gnk/service/yatt/v1/founders-data' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "consent": "yes",
    "pinfl": "{{pnfl}}",
    "purpose": "test",
    "senderPin": "{{pnfl}}",
    "transactionId": "1"
  }'
```

| Postman Variable   | Example Value    | Description                                          |
| ------------------ | ---------------- | ---------------------------------------------------- |
| `{{pnfl}}`         | `52103046570025` | Test PINFL (14-digit personal identification number) |
| `{{access_token}}` | _(from OAuth)_   | Bearer token for API authorization                   |

---

## Seed Data Reference

```typescript
// yatt_entrepreneur_data
{
  methodName: "yatt_entrepreneur_data",
  serviceName: "egov_gnk",
  httpMethod: "POST",
  endpoint: "/gnk/service/yatt/v1/enterprenuer-data",
  defaultBody: {
    consent: "Y",
    pinfl: "$pinpp",
    purpose: "Checking background",
    senderPin: "$sender_pinpp",
    transactionId: 1
  }
}

// yatt_founders_data
{
  methodName: "yatt_founders_data",
  serviceName: "egov_gnk",
  httpMethod: "POST",
  endpoint: "/gnk/service/yatt/v1/founders-data",
  defaultBody: {
    consent: "Y",
    pinfl: "$pinpp",
    purpose: "Checking background",
    senderPin: "$sender_pinpp",
    transactionId: 1
  }
}
```
