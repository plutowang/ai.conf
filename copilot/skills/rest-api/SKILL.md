---
name: rest-api
description: Auto-apply when designing or implementing REST APIs. Trigger this skill when the user asks to create, modify, or debug REST endpoints, API contracts, HTTP conventions, or RESTful resource modeling.
---

# REST API Design Expert

You are an expert in **REST API Design**. You strictly adhere to resource-oriented architecture and HTTP semantics.

<red_lines>

- **No verbs in URLs** — Use HTTP methods, not `/getUser` or `/createPost`.
- **Plural nouns** for collections: `/users`, `/posts`, `/comments`.
- **kebab-case** for multi-word paths: `/user-profiles`, `/order-items`.
- Never expose stack traces, internal file paths, database errors, or implementation details in an error response. Log them server-side and return the opaque `traceId` instead — it is the only safe way to correlate a client report with a server log.
- Use **cursor-based pagination** for large datasets — never offset pagination for large tables.
</red_lines>

<standards>
**URL Structure**

- **Nested resources** for relationships: `/users/{userId}/posts`

Examples:

```http
GET    /users              # List users
POST   /users              # Create user
GET    /users/{id}         # Get user
PATCH  /users/{id}          # Update user (partial)
PUT    /users/{id}          # Replace user (full)
DELETE /users/{id}          # Delete user

GET    /users/{userId}/posts    # Get user's posts
POST   /users/{userId}/posts    # Create post for user
```

**Anti-Patterns** — never do these:

```http
# Bad: verbs in URLs
GET /getUsers
POST /createUser
POST /deleteUser

# Bad: nouns as verbs
GET /users/list
POST /users/add

# Bad: inconsistent casing
GET /user_profiles  (should be /user-profiles)
```

**HTTP Methods**

| Method    | Semantics          | Idempotent | Safe |
| --------- | ------------------ | ---------- | ---- |
| `GET`     | Read resource      | Yes        | Yes  |
| `POST`    | Create resource    | No         | No   |
| `PUT`     | Replace resource   | Yes        | No   |
| `PATCH`   | Partial update     | No         | No   |
| `DELETE`  | Remove resource    | Yes        | No   |
| `HEAD`    | Headers only       | Yes        | Yes  |
| `OPTIONS` | Capabilities       | Yes        | Yes  |

**Standard Error Format**

Use a consistent error response format across all endpoints:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "age",
        "message": "Must be a positive integer",
        "code": "INVALID_TYPE"
      }
    ],
    "traceId": "abc123-def456"
  }
}
```

**Standard Error Codes**

| HTTP Status | Code                  | Use Case                              |
| ----------- | --------------------- | ------------------------------------- |
| 400         | `BAD_REQUEST`         | Malformed request                     |
| 400         | `VALIDATION_ERROR`    | Invalid input                         |
| 401         | `UNAUTHORIZED`        | Missing or invalid authentication     |
| 403         | `FORBIDDEN`           | Authenticated but not permitted       |
| 404         | `NOT_FOUND`           | Resource doesn't exist                |
| 409         | `CONFLICT`            | Resource conflict (duplicate, etc.)   |
| 422         | `UNPROCESSABLE`       | Semantically invalid input            |
| 429         | `RATE_LIMITED`        | Too many requests                     |
| 500         | `INTERNAL_ERROR`      | Unexpected server error               |
| 503         | `SERVICE_UNAVAILABLE` | Temporarily unavailable               |

**HTTP Status Code Guidelines**

- `200 OK` — Successful GET, PATCH, PUT, DELETE
- `201 Created` — Successful POST creating a resource
- `202 Accepted` — Async operation accepted
- `204 No Content` — Successful DELETE with no body
- `400 Bad Request` — Client error (validation, malformed)
- `401 Unauthorized` — Authentication required
- `403 Forbidden` — Authenticated but not authorized
- `404 Not Found` — Resource doesn't exist
- `409 Conflict` — Resource state conflict
- `422 Unprocessable Entity` — Valid syntax but semantic errors
- `429 Too Many Requests` — Rate limit exceeded
- `500 Internal Server Error` — Server-side error

**Pagination**

Cursor pagination response:

```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTAwfQ==",
    "prevCursor": null,
    "hasNext": true,
    "hasPrev": false,
    "totalCount": 1500
  }
}
```

Request parameters:

```bash
GET /users?first=20&after=eyJpZCI6MTAwfQ==
GET /posts?last=10&before=eyJpZCI6MjAwfQ==
```

| Parameter | Purpose                                             |
| --------- | --------------------------------------------------- |
| `first`  | Number of items to return (forward)                 |
| `after`  | Cursor for forward pagination                       |
| `last`   | Number of items to return (backward)                |
| `before` | Cursor for backward pagination                      |
| `filter` | JSON-encoded filter object                          |
| `sort`   | Field and direction (e.g., `createdAt:desc`)      |

**Idempotency**

For critical POST operations, support idempotency keys:

```bash
Idempotency-Key: <unique-client-generated-key>
```

Idempotency response:

```http
HTTP/1.1 201 Created
Idempotency-Key: abc123
```

Implementation notes:

- Store idempotency keys with TTL (24 hours recommended)
- Return cached response for duplicate keys
- Keys should be UUIDs or similar high-entropy values

**API Versioning**

URL path versioning (recommended):

```bash
/api/v1/users
/api/v2/users
```

Version lifecycle:

| Status       | Description                |
| ------------ | -------------------------- |
| `current`    | Latest stable version      |
| `deprecated` | Still supported, migration recommended |
| `sunset`     | Security patches only, migration required |
| `closed`     | No longer available        |

Deprecation headers:

```http
Deprecation: true
Sunset: Sat, 31 Dec 2025 23:59:59 GMT
Link: <https://api.example.com/v2/users>; rel="successor-version"
```

**Input Validation**

- Validate at **boundary** (entry point), not in business logic
- Reject early with clear, actionable error messages
- Use schema validation (Zod, JSON Schema, etc.)

Example validation error:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address",
        "code": "INVALID_FORMAT"
      }
    ]
  }
}
```

Common validation types:

| Type       | Rule Example                                     |
| ---------- | ------------------------------------------------ |
| `required` | Field must be present                            |
| `string`   | Must be a string                                 |
| `email`    | Valid email format                               |
| `uuid`     | Valid UUID v4 format                             |
| `url`      | Valid URL                                        |
| `minLength`| Minimum string length                            |
| `maxLength`| Maximum string length                            |
| `minimum`  | Minimum numeric value                            |
| `maximum`  | Maximum numeric value                            |
| `enum`     | Must be one of allowed values                     |
| `pattern`  | Must match regex pattern                          |

**Rate Limiting**

Response headers:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640000000
Retry-After: 60
```

Rate limit exceeded response:

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 60
Content-Type: application/json

{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded. Retry after 60 seconds.",
    "retryAfter": 60
  }
}
```

Rate limit tiers:

| Tier      | Requests/minute | Use Case |
| --------- | --------------- | ---- |
| Standard  | 60              | Default              |
| Elevated  | 600             | Authenticated        |
| Partner   | 6000            | Business partners    |
| Internal  | Unlimited       | Service-to-service   |

**Request/Response Conventions**

- Always specify Content-Type and Accept headers:

```http
Content-Type: application/json
Accept: application/json
```

- Dates in **ISO 8601** with UTC timezone:

```json
{
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

- Null vs empty semantics:

| Value    | Meaning                                           |
| ------ | ------------------------------------------------- |
| `null`   | Field exists but has no value                     |
| `[]`     | Empty collection                                   |
| `""`     | Empty string (rarely use)                         |
| omitted  | Field not included (sparse fields)                |

- Allow clients to request specific fields:

```bash
GET /users?fields=id,name,email
```

**Async Operations**

Accepted response:

```http
HTTP/1.1 202 Accepted
Location: /operations/12345
```

Operation resource:

```json
{
  "id": "12345",
  "status": "processing",
  "createdAt": "2024-01-15T10:30:00Z",
  "estimatedCompletion": "2024-01-15T10:35:00Z"
}
```

Webhook alternative for async completion:

```json
{
  "id": "12345",
  "status": "processing",
  "webhookUrl": "https://client.example.com/callbacks/operation/12345"
}
```

**Security**

- Authentication: Bearer tokens in Authorization header; API keys for server-to-server; JWT or OAuth 2.0 for user authentication
- Authorization: implement RBAC or ABAC; validate permissions at endpoint level; audit log all authorization failures
- CORS headers:

```http
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization, Idempotency-Key
Access-Control-Max-Age: 86400
```

</standards>

<pre_flight_check>
Before finalizing any REST API design, verify:

- [ ] URLs use plural nouns, kebab-case, no verbs
- [ ] Correct HTTP methods used
- [ ] Consistent error format with machine-readable codes
- [ ] Correct HTTP status codes
- [ ] Cursor-based pagination implemented
- [ ] Idempotency keys supported for POST
- [ ] Input validation at the boundary with clear errors
- [ ] Rate limiting headers present
- [ ] Versioning strategy defined
- [ ] Security headers configured
</pre_flight_check>
