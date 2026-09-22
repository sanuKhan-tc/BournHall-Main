# Penetration Test Checklist

## Scope and safety

- Target: local/development Bourn Hall environment only.
- No destructive actions, credential guessing, bulk spam, data deletion, or third-party testing.
- Sensitive values are excluded from evidence.

## Completed safe tests

| Area | Test | Result |
|---|---|---|
| REST auth | Anonymous `POST /wp-json/brounhall/v1/appointments` | HTTP 401; HMAC required |
| REST method | Anonymous `GET /wp-json/brounhall/v1/appointments` | HTTP 404; no public read route |
| Nonce | Correctly signed nonce request | HTTP 200; nonce returned |
| Published content | Public treatments/doctors/clinics collections | HTTP 200 locally |
| GraphQL | Safe introspection probes | HTTP 404 locally; runtime unavailable |
| PHP | Project plugin syntax | All files passed `php -l` |
| TypeScript | `npx tsc --noEmit` | PASS |
| Dependency audit | `npm audit --json` | 0 reported vulnerabilities |
| Diff hygiene | `git diff --check` | PASS |
| Build | `npm run build` | FAIL: Google Fonts network fetch unavailable |
| Lint | `npm run lint` | Did not complete; stopped after extended no-output run |

## Required negative tests before release

### Appointment proxy

- Missing/invalid JSON and non-JSON content type.
- Oversized body.
- Missing/foreign Origin and cross-site form POST.
- Missing consent, malformed email/phone, invalid enum, control characters, long message.
- Empty and filled honeypot.
- Too-fast and expired `startedAt`.
- Invalid/replayed HMAC timestamp/signature/request ID.
- Invalid/replayed WP nonce.
- Same client token repeated concurrently and sequentially.
- Same normalized payload with changing tokens.
- Per-source burst versus unrelated-source request.
- Downstream WordPress unavailable/slow.
- Notification failure behavior and retry behavior.

### CMS/REST

- Draft/private/revision requests for every custom detail endpoint.
- Invalid slugs: traversal, slash, encoded slash, scheme, query-like values.
- Unknown doctor type.
- Bounded collection behavior under large content counts.
- Raw meta/debug field exposure.

### Frontend URLs and rendering

- `//external.example`, `/\\external`, encoded `javascript:`, mixed-case schemes, `data:`, `vbscript:`.
- CMS strings containing `</script><script>` through every JSON-LD path.
- Malformed REST JSON and oversized REST responses.
- Missing/invalid WordPress base URL and GraphQL URL.

### WordPress/runtime

- Public `/wp-json/wp/v2` exposure and CPT visibility in production.
- WPGraphQL anonymous introspection, mutation denial, complexity/pagination limits, and private field access.
- XML-RPC policy, debug/display-errors behavior, admin MFA, file editor, uploads, WAF, and backup access.

