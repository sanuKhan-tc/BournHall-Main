# BrounHall local observability

This directory extends the existing local Grafana, Prometheus, and Blackbox
Exporter stack with Loki and Grafana Alloy. The existing Platform Health
dashboard and probes are retained. Loki is local-only and is not published on
a host port.

Copy `.env.example` to `.env` for local configuration. The `WPE_*` entries are
reserved placeholders for the future remote log collector; they are not read
by the current Compose services. Keep tokens and private-key paths only in the
ignored `.env` or deployment secret manager.

## Start and stop

```powershell
docker compose up -d
docker compose ps
docker compose logs loki
docker compose logs alloy
```

Normal shutdown keeps monitoring data:

```powershell
docker compose down
```

`docker compose down -v` is a destructive reset: it deletes Grafana,
Prometheus, Loki, and Alloy volumes. Use it only when intentionally resetting
local monitoring history.

## Services

| Service | Image | Purpose | Host port |
| --- | --- | --- | --- |
| Grafana | existing `grafana/grafana:latest` | dashboards and Explore | 3003 |
| Prometheus | existing `prom/prometheus:latest` | metrics | 9090 |
| Blackbox | existing `prom/blackbox-exporter:latest` | HTTP probes | 9115 |
| Loki | `grafana/loki:3.7.0` | filesystem-backed log storage | internal only |
| Alloy | `grafana/alloy:v1.20.0` | file collection and redaction | internal only |

Loki retains approximately seven days using its compactor and `loki-data`
volume. Filesystem retention is time-based; Docker disk usage should still be
checked periodically because Loki does not enforce a host filesystem quota.

## Log sources

The application loggers already emit one JSON object per line to server-side
stdout/stderr (Next.js) and the PHP error log (WordPress). Alloy does not read
browser logs and does not access WordPress credentials or uploads. For this
local stack, structured JSONL is collected from:

```text
monitoring/logs/frontend/*.jsonl
monitoring/logs/wordpress/*.jsonl
```

For a local Next.js run, set the server-only `LOG_FILE_PATH` sink to the
dedicated file while retaining the terminal output:

```powershell
New-Item -ItemType Directory -Force monitoring/logs/frontend | Out-Null
Set-Location frontend
$env:LOG_FILE_PATH = "..\monitoring\logs\frontend\next.jsonl"
npm run dev
```

The sink is disabled in production and failures to write it never interrupt
the application. Alloy still drops any malformed lines. Do not redirect
browser console output or request bodies here.

For WP Engine Headless deployments, do not set `LOG_FILE_PATH`. Use the
existing JSON stdout/stderr logger; WP Engine exposes Node runtime logs in the
environment Logs view. A persistent application file path is not part of the
Headless runtime contract.

WordPress continues to write the same structured records through PHP
`error_log`; in the local XAMPP setup that is Apache's error log. Set the
server-only `BROUNHALL_LOG_FILE` environment variable for the PHP/Apache
process to `monitoring/logs/wordpress/wordpress.jsonl` to enable the optional
local file sink. It is disabled for production. Do not mount or ingest the
whole WordPress tree, uploads, database, or credentials.

## Schema, labels, and correlation

The existing application schema is preserved: `timestamp`, `level`, `service`,
`environment`, `event`, and `message`, with optional `request_id`, `trace_id`,
`operation`, `method`, `route`, `status_code`, `duration_ms`, `cache_status`,
and `error_type`.

Alloy uses only low-cardinality Loki labels:

```text
application=brounhall
environment=development
service=frontend|wordpress
level=debug|info|warn|error
```

`request_id` remains a JSON field, not a label. Search it without increasing
Loki index cardinality:

```logql
{application="brounhall"} |= "req_"
{application="brounhall"} | json | request_id="req_example"
{application="brounhall", service="frontend"} | json | level="error"
```

Alloy drops malformed input and lines containing sensitive JSON keys or the
synthetic redaction test values. The application logger's allow-list remains
the primary privacy boundary; Alloy is a second local ingestion guard.

## Grafana

Grafana provisions both datasources without manual setup:

- Prometheus: `http://prometheus:9090`, UID `prometheus`
- Loki: `http://loki:3100`, UID `loki`

The provisioned dashboard **BrounHall — Application Logs & Errors** includes
error and warning counts, live logs, error logs, and slow operations over
2000ms. The existing **BrounHall — Platform Health** dashboard remains
Prometheus-backed.

Useful Explore queries:

```logql
{application="brounhall"}
{application="brounhall", service="wordpress"}
{application="brounhall"} | json | level="error"
{application="brounhall"} | json | duration_ms > 2000
```

## Validation

```powershell
docker compose config
docker compose up -d
docker compose ps
curl http://localhost:3003/api/health
```

Loki and Alloy use minimal images without a shell or HTTP client, so Compose
does not add a fragile in-container healthcheck. Verify Loki through Grafana's
Loki datasource or from a temporary network client when needed:

```powershell
docker run --rm --network monitoring_default curlimages/curl:8.10.1 http://loki:3100/ready
docker run --rm --network monitoring_default curlimages/curl:8.10.1 http://alloy:12345/-/ready
```

For a controlled ingestion check, write a synthetic safe JSON line to one of
the ignored `.jsonl` files, wait briefly, then query Loki from Grafana Explore.
Also test that synthetic values such as `TEST_PASSWORD_DO_NOT_LOG`,
`TEST_TOKEN_DO_NOT_LOG`, `observability-test@example.invalid`, and
`+971500000000` never appear in Loki. Never use real patient data.

The original Prometheus probes remain unchanged: `frontend`, `wordpress`,
`wordpress-health`, and `treatment-api`, with `application="brounhall"` and
`environment="development"` labels.
