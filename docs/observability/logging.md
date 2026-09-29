# Bourn Hall logging and observability

The frontend and WordPress plugin emit newline-delimited JSON to their normal
server logs. The format is intentionally vendor-neutral so WP Engine logs can
later be collected by Grafana Alloy and sent to Loki without changing the
application code.

## Canonical fields

Every application event includes:

```json
{
  "timestamp": "2026-09-29T10:30:00.000Z",
  "level": "info",
  "service": "brounhall-frontend",
  "environment": "production",
  "event": "wordpress_request_completed",
  "message": "WordPress request completed",
  "request_id": "req_opaque-id",
  "duration_ms": 186,
  "status_code": 200
}
```

Optional fields are limited to safe operational data: `trace_id`, `operation`,
`method`, `route`, `status_code`, `duration_ms`, `cache_status`, `error_type`,
`attempt`, `response_bytes`, `retry_after`, `content_type`, and `locale`.

Events use lowercase `snake_case`. Levels are `debug`, `info`, `warn`, and
`error`. Frontend successful WordPress reads are debug-level to avoid
production noise; failures are error-level.

## Frontend

The logger is in `frontend/src/lib/observability/`. Server-side WordPress
requests generate or validate an opaque `req_...` ID and send it as
`X-Request-ID`. API form routes accept a valid incoming ID or generate one and
forward it as both `X-Request-ID` and the existing signed request header.

Configuration is server-only:

```text
LOG_LEVEL=info
SERVICE_NAME=brounhall-frontend
WORDPRESS_ENVIRONMENT=production
```

Production defaults to `info` and suppresses debug logs unless explicitly
overridden. No request bodies, response bodies, query strings, headers, form
fields, GraphQL variables, or exception messages are logged.

## WordPress

The plugin logger is in
`backend/wp-content/plugins/brounhall-headless/includes/observability/`.
`BROUNHALL_LOG_LEVEL` controls the level and defaults to `info`; debug is
disabled in production by default. Existing appointment security and
decryption events now use the centralized logger.

The minimal health endpoint is:

```text
GET /wp-json/brounhall/v1/health
```

It returns only `status` and `timestamp`, and does not expose versions,
credentials, paths, hostnames, database details, or plugin inventory.

## Privacy policy

The logger uses an allow-list rather than attempting to scrub arbitrary
objects. Email, phone, names, addresses, medical data, messages, notes,
passwords, authorization material, cookies, tokens, API keys, and request or
response payloads are not accepted as log fields.

Request IDs are opaque random identifiers. They are useful as structured
metadata but must not be configured as Loki labels.

## Loki / Alloy readiness

Use low-cardinality labels only: `service`, `environment`, and optionally a
bounded `component`. Keep `request_id`, `trace_id`, routes with parameters,
slugs, exception text, and timestamps as structured log fields. No Grafana,
Loki, Tempo, Prometheus, or Alloy is installed by this change.

## Production recommendations

Keep public WordPress debug display disabled. Route PHP and Next.js stdout/
stderr through the hosting platform's existing log collection. Configure
retention, access control, alerting, and Alloy/Loki transport as a separate
infrastructure task.
