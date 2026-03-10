# GCP Document REST -- /gcp/docrest/v1

**Category:** passport
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint provides passport data retrieval via document number and PINFL. It supports two methods: lookup by PINFL + passport series/number, and a more general lookup that also accepts a birth date. Both return the same GCP response structure and apply identical normalization to a standardized passport data format.

---

## Methods

### `passport_by_pinfl_document`

| Field         | Value             |
| ------------- | ----------------- |
| HTTP Method   | POST              |
| Endpoint      | `/gcp/docrest/v1` |
| Service       | egov_main         |
| Timeout       | 60000ms           |
| Requires Auth | Yes               |

#### Request Body

```json
{
  "transaction_id": 1,
  "is_consent": "Y",
  "sender_pinfl": "$sender_pinpp",
  "langId": 1,
  "document": "$passport_series$passport_number",
  "pinpp": "$pinpp",
  "is_photo": "N",
  "Sender": "M"
}
```

#### Placeholder Variables

| Placeholder                        | Source                                                            | Description                                                |
| ---------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------- |
| `$sender_pinpp`                    | search_criteria.sender_pinpp                                      | PINFL of the requesting sender                             |
| `$passport_series$passport_number` | search_criteria.passport_series + search_criteria.passport_number | Passport series and number concatenated (e.g. `AA1234567`) |
| `$pinpp`                           | search_criteria.pinpp                                             | 14-digit PINFL of the person being looked up               |

#### Response Structure

```json
{
  "result": 1,
  "Data": [
    {
      "transaction_id": "string",
      "current_pinpp": "string",
      "current_document": "string",
      "pinpps": "string",
      "surnamelat": "string",
      "namelat": "string",
      "patronymlat": "string",
      "surnamecyr": "string",
      "namecyr": "string",
      "patronymcyr": "string",
      "engsurname": "string",
      "engname": "string",
      "birth_date": "string",
      "birthplace": "string",
      "birthcountry": "string",
      "birthcountryid": "string",
      "livestatus": "string",
      "nationality": "string",
      "nationalityid": "string",
      "citizenship": "string",
      "citizenshipid": "string",
      "sex": "string",
      "documents": [
        {
          "type": "string",
          "document": "string",
          "docgiveplace": "string",
          "docgiveplaceid": "string",
          "datebegin": "string",
          "dateend": "string",
          "status": "string"
        }
      ]
    }
  ]
}
```

#### Custom Transform

Extracts the first entry from `data.Data` and normalizes it to the `IPassportNormalizedData` structure:

```json
{
  "surname": "surnamelat",
  "firstname": "namelat",
  "patronymic": "patronymlat",
  "birthDate": "birth_date",
  "gender": "sex",
  "nationality": "nationality",
  "birthPlace": "birthplace",
  "documentNumber": "current_document",
  "expiryDate": "documents[0].dateend",
  "issueDate": "documents[0].datebegin",
  "pinfl": "current_pinpp"
}
```

#### Error Handling

- Parses error code `303001` as `NOT_FOUND`.
- Detects Russian text containing the substring `"ne nayden"` / `"topilmadi"` (Uzbek) in the `comments` field and treats them as not-found errors.

---

### `passport_data`

| Field         | Value             |
| ------------- | ----------------- |
| HTTP Method   | POST              |
| Endpoint      | `/gcp/docrest/v1` |
| Service       | egov_main         |
| Timeout       | 60000ms           |
| Requires Auth | Yes               |

#### Request Body

```json
{
  "transaction_id": null,
  "is_consent": "Y",
  "sender_pinfl": "$sender_pinpp",
  "langId": 1,
  "document": "$document",
  "pinpp": "$pinpp",
  "birth_date": "$birth_date",
  "is_photo": "N",
  "Sender": "P"
}
```

#### Placeholder Variables

| Placeholder     | Source                       | Description                                  |
| --------------- | ---------------------------- | -------------------------------------------- |
| `$sender_pinpp` | search_criteria.sender_pinpp | PINFL of the requesting sender               |
| `$document`     | search_criteria.document     | Passport document identifier                 |
| `$pinpp`        | search_criteria.pinpp        | 14-digit PINFL of the person being looked up |
| `$birth_date`   | search_criteria.birth_date   | Date of birth of the person being looked up  |

#### Response Structure

Same GCP response format as `passport_by_pinfl_document` above.

#### Custom Transform

Same normalization to `IPassportNormalizedData` as `passport_by_pinfl_document`.

#### Error Handling

Same error handling as `passport_by_pinfl_document` -- parses `303001` as `NOT_FOUND` and detects not-found text patterns in comments.

---

## Parent-Child Dependencies

None.

## Postman Examples

### `passport_by_pinfl_document`

> Получает паспортные данные по ПИНФЛ и документу. Для получения фото установить is_photo: "Y".

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gcp/docrest/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "transaction_id": 1,
  "is_consent": "Y",
  "sender_pinfl": "31002730280037",
  "langId": 1,
  "document": "AB8069344",
  "pinpp": "31002730280037",
  "is_photo": "N",
  "Sender": "M"
}'
```

| Postman Variable | Example Value    | Description                         |
| ---------------- | ---------------- | ----------------------------------- |
| `{{pnfl}}`       | `31002730280037` | Test PINFL (used as `sender_pinfl`) |

### `passport_data`

#### By document and birthdate

> Получает паспортные данные по документу и дате рождения.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gcp/docrest/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "transaction_id": 3,
  "is_consent": "Y",
  "sender_pinfl": "31002730280037",
  "langId": 1,
  "document": "AB5591779",
  "birth_date": "2000-01-01",
  "is_photo": "N",
  "Sender": "M"
}'
```

| Postman Variable | Example Value    | Description                         |
| ---------------- | ---------------- | ----------------------------------- |
| `{{pnfl}}`       | `31002730280037` | Test PINFL (used as `sender_pinfl`) |

#### By PINFL and birthdate

> Получает паспортные данные по ПИНФЛ и дате рождения.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gcp/docrest/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "transaction_id": 3,
  "is_consent": "Y",
  "sender_pinfl": "31002730280037",
  "langId": 1,
  "pinpp": "31002730280037",
  "birth_date": "1973-02-10",
  "is_photo": "Y",
  "Sender": "P"
}'
```

| Postman Variable | Example Value    | Description                                     |
| ---------------- | ---------------- | ----------------------------------------------- |
| `{{pnfl}}`       | `31002730280037` | Test PINFL (used as `sender_pinfl` and `pinpp`) |

---

## Seed Data Reference

```typescript
// passport_by_pinfl_document
{
  methodName: "passport_by_pinfl_document",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/gcp/docrest/v1",
  defaultBody: {
    transaction_id: 1,
    is_consent: "Y",
    sender_pinfl: "$sender_pinpp",
    langId: 1,
    document: "$passport_series$passport_number",
    pinpp: "$pinpp",
    is_photo: "N",
    Sender: "M"
  }
}

// passport_data
{
  methodName: "passport_data",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/gcp/docrest/v1",
  defaultBody: {
    transaction_id: null,
    is_consent: "Y",
    sender_pinfl: "$sender_pinpp",
    langId: 1,
    document: "$document",
    pinpp: "$pinpp",
    birth_date: "$birth_date",
    is_photo: "N",
    Sender: "P"
  }
}
```
