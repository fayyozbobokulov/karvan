# Kadastr Cadastral Number -- /kadastr/cadnum/v3

**Category:** property
**Service:** egov_kadastr
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint provides property (real estate) information retrieval from the State Cadastre system. It supports lookups by PINFL (individual owner), TIN (organizational owner), or cadastral number (specific property). All methods require sender TIN for authorization and audit purposes.

---

## Methods

### `property_by_pinfl`

| Field         | Value                |
| ------------- | -------------------- |
| HTTP Method   | POST                 |
| Endpoint      | `/kadastr/cadnum/v3` |
| Service       | egov_kadastr         |
| Timeout       | 60000ms              |
| Requires Auth | Yes                  |

#### Request Body

```json
{
  "id": 1,
  "purpose": "Checking background",
  "tin": "$sender_tin",
  "pinfl": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder   | Source                     | Description                          |
| ------------- | -------------------------- | ------------------------------------ |
| `$sender_tin` | search_criteria.sender_tin | TIN of the requesting organization   |
| `$pinpp`      | search_criteria.pinpp      | 14-digit PINFL of the property owner |

---

### `property_by_tin`

| Field         | Value                |
| ------------- | -------------------- |
| HTTP Method   | POST                 |
| Endpoint      | `/kadastr/cadnum/v3` |
| Service       | egov_kadastr         |
| Timeout       | 60000ms              |
| Requires Auth | Yes                  |

#### Request Body

```json
{
  "id": 1,
  "purpose": "Checking background",
  "tin": "$sender_tin",
  "org_tin": "$tin"
}
```

#### Placeholder Variables

| Placeholder   | Source                     | Description                                               |
| ------------- | -------------------------- | --------------------------------------------------------- |
| `$sender_tin` | search_criteria.sender_tin | TIN of the requesting organization                        |
| `$tin`        | search_criteria.tin        | TIN of the organization whose property is being looked up |

---

### `property_by_cadastral`

| Field         | Value                |
| ------------- | -------------------- |
| HTTP Method   | POST                 |
| Endpoint      | `/kadastr/cadnum/v3` |
| Service       | egov_kadastr         |
| Timeout       | 60000ms              |
| Requires Auth | Yes                  |

#### Request Body

```json
{
  "id": 1,
  "purpose": "Checking background",
  "tin": "$sender_tin",
  "cad_num": "$cadastral_number"
}
```

#### Placeholder Variables

| Placeholder         | Source                           | Description                               |
| ------------------- | -------------------------------- | ----------------------------------------- |
| `$sender_tin`       | search_criteria.sender_tin       | TIN of the requesting organization        |
| `$cadastral_number` | search_criteria.cadastral_number | Cadastral number of the specific property |

---

## Postman Examples

### `property_by_cadastral`

> Получает полную информацию об объекте недвижимости по кадастровому номеру, включая адрес, собственника.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/kadastr/cadnum/v3' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": 1,
    "purpose": "Davlat xizmatlarini ko'\''rsatish uchun",
    "tin": "{{tin}}",
    "cad_num": "10:09:06:03:01:5007:0001:017"
  }'
```

| Postman Variable | Example Value                  | Description                        |
| ---------------- | ------------------------------ | ---------------------------------- |
| `{{tin}}`        | _(sender TIN)_                 | TIN of the requesting organization |
| `cad_num`        | `10:09:06:03:01:5007:0001:017` | Test cadastral number              |

### `property_by_pinfl`

> Получает список кадастровых номеров объектов недвижимости, принадлежащих лицу по ПИНФЛ.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/kadastr/cadnum/v3' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": 1,
    "purpose": "Davlat xizmatlarini ko'\''rsatish uchun",
    "tin": "{{tin}}",
    "pinfl": "30106765830010"
  }'
```

| Postman Variable | Example Value    | Description                        |
| ---------------- | ---------------- | ---------------------------------- |
| `{{tin}}`        | _(sender TIN)_   | TIN of the requesting organization |
| `pinfl`          | `30106765830010` | Test PINFL                         |

### `property_by_tin`

> Получает список кадастровых номеров объектов недвижимости юридического лица по ИНН.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/kadastr/cadnum/v3' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": 1,
    "purpose": "Davlat xizmatlarini ko'\''rsatish uchun",
    "tin": "306687897",
    "org_tin": "{{tin}}"
  }'
```

| Postman Variable | Example Value        | Description                                               |
| ---------------- | -------------------- | --------------------------------------------------------- |
| `{{tin}}`        | _(organization TIN)_ | TIN of the organization whose property is being looked up |
| `tin`            | `306687897`          | Test sender TIN                                           |

---

## Seed Data Reference

```typescript
// property_by_pinfl
{
  methodName: "property_by_pinfl",
  serviceName: "egov_kadastr",
  httpMethod: "POST",
  endpoint: "/kadastr/cadnum/v3",
  defaultBody: {
    id: 1,
    purpose: "Checking background",
    tin: "$sender_tin",
    pinfl: "$pinpp"
  }
}

// property_by_tin
{
  methodName: "property_by_tin",
  serviceName: "egov_kadastr",
  httpMethod: "POST",
  endpoint: "/kadastr/cadnum/v3",
  defaultBody: {
    id: 1,
    purpose: "Checking background",
    tin: "$sender_tin",
    org_tin: "$tin"
  }
}

// property_by_cadastral
{
  methodName: "property_by_cadastral",
  serviceName: "egov_kadastr",
  httpMethod: "POST",
  endpoint: "/kadastr/cadnum/v3",
  defaultBody: {
    id: 1,
    purpose: "Checking background",
    tin: "$sender_tin",
    cad_num: "$cadastral_number"
  }
}
```
