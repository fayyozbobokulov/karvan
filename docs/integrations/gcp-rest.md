# GCP REST -- /gcp/rest/v1

**Category:** passport
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint provides passport data retrieval by PINFL and birth date. It returns the standard GCP passport response and applies the same normalization as other passport category endpoints.

---

## Methods

### `passport_by_pinfl_birthdate`

| Field         | Value          |
| ------------- | -------------- |
| HTTP Method   | POST           |
| Endpoint      | `/gcp/rest/v1` |
| Service       | egov_main      |
| Timeout       | 60000ms        |
| Requires Auth | Yes            |

#### Request Body

```json
{
  "transaction_id": 1,
  "is_consent": "Y",
  "sender_pinfl": "$sender_pinpp",
  "langId": 1,
  "birth_date": "$birth_date",
  "pinpp": "$pinpp",
  "is_photo": "N",
  "Sender": "M"
}
```

#### Placeholder Variables

| Placeholder     | Source                       | Description                                  |
| --------------- | ---------------------------- | -------------------------------------------- |
| `$sender_pinpp` | search_criteria.sender_pinpp | PINFL of the requesting sender               |
| `$birth_date`   | search_criteria.birth_date   | Date of birth of the person being looked up  |
| `$pinpp`        | search_criteria.pinpp        | 14-digit PINFL of the person being looked up |

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

## Parent-Child Dependencies

None.

## Seed Data Reference

```typescript
{
  methodName: "passport_by_pinfl_birthdate",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/gcp/rest/v1",
  defaultBody: {
    transaction_id: 1,
    is_consent: "Y",
    sender_pinfl: "$sender_pinpp",
    langId: 1,
    birth_date: "$birth_date",
    pinpp: "$pinpp",
    is_photo: "N",
    Sender: "M"
  }
}
```
