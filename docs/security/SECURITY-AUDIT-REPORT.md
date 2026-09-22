# Security Audit Report

## 1. Executive Summary

Assessment result: **BLOCKED — high-risk production security defects remain**.

The application has a sound high-level trust boundary for the appointment path: the browser posts to Next.js, and Next.js signs the server-to-server WordPress request. WordPress REST records are private, published-only content endpoints are bounded, and the custom plugin uses capability checks/nonces for admin writes. No direct evidence of SQL injection, command execution, anonymous draft/private CMS exposure, or a browser-bundled WordPress secret was found.

Production is not ready because the public appointment proxy remains an abuse-sensitive unauthenticated endpoint. A remote party can automate requests to Next.js, consume the shared WordPress rate window, force a nonce request plus a signed WordPress submission attempt, create private appointment/PII records, and trigger configured notification delivery. The current global limiter is not requester-scoped, so one source can degrade all visitors. There is also a confirmed protocol-relative URL acceptance bug in the shared CMS link validator, environment/indexing policy is hardcoded for indexing, and required response-security headers are not configured in the repository.

## 2. Scope

- Parent repository and orchestration documentation.
- `frontend/` Next.js application at reviewed SHA `da1a0bd6bc95923bb590aeadde4e1cab6c83d79a`.
- `backend/` WordPress project/plugin at reviewed SHA `607bc3c8ce7a52c12c11f6827423317425514f12`.
- Project-owned REST, GraphQL integration code, public forms, CMS mappers, URL handling, configuration, and local runtime checks.
- Safe local/development requests only. No destructive or third-party testing.

## 3. Repository / Commit Baseline

The parent is on branch `integration`, starting SHA `0a3743a613da749ef109317c8bd8c7a166f42156` as observed. The frontend and backend worktrees were dirty during review; the parent/submodule Git status command intermittently failed on this Windows environment with a Git `CreateFileMapping` error, so a clean parent status could not be independently confirmed. No secrets are included in this report.

The repository does not contain the documented `docs/headless/` plan directory. The available `docs/agent/` documents and both submodule `AGENTS.md`/project files were used instead.

## 4. Architecture and Trust Boundaries

```text
Browser
  |-- public pages and appointment POST
  v
Next.js server/app routes
  |-- server-only WordPress REST reads
  |-- server-only HMAC proxy for appointments
  v
WordPress
  |-- public published REST content
  |-- HMAC-protected appointment REST
  |-- authenticated admin/CMS writes
```

Observed surfaces:

| Surface | Location | Trust/authentication |
|---|---|---|
| Public Next pages | `frontend/src/app/**` | Anonymous |
| Appointment proxy | `frontend/src/app/api/appointments/route.ts` | Anonymous browser input; server-only secret downstream |
| WordPress appointment nonce | `brounhall/v1/appointments/nonce` | HMAC timestamp/signature/request ID |
| WordPress appointment create | `brounhall/v1/appointments` | HMAC, timestamp, replay ID, WP nonce, validation |
| Published doctors/clinics/treatments | `brounhall/v1/{doctors,clinics,treatments}` | Anonymous, `__return_true`, publish filter |
| WordPress core REST pages/posts/media | WordPress core | Public published content behavior |
| GraphQL integration | `frontend/src/lib/wordpress.ts` | Server-side fixed query; local endpoint was unavailable |
| Admin/CMS writes | WordPress admin meta boxes/settings | WordPress capabilities and nonces |
| Preview/revalidation | Not found in project code | Not implemented / not verifiable |
| Upload/media | WordPress core media | Not project-owned; hosting hardening required |

## 5. Methodology

Manual source review, trust-boundary tracing, endpoint enumeration, safe negative requests against the local WordPress host, PHP syntax checks, TypeScript checking, build/lint/audit attempts, configuration review, and dependency metadata review. No destructive exploitation, credential guessing, bulk form submissions, or third-party testing was performed.

## 6. Tools Executed

| Command/check | Result | Security relevance |
|---|---|---|
| `npx tsc --noEmit` | PASS | Type safety |
| `npm audit --json` | PASS; 0 reported vulnerabilities | Dependency baseline only |
| PHP lint for all project plugin PHP files | PASS | Syntax/runtime loading baseline |
| `git diff --check` | PASS | Patch hygiene |
| `npm run lint` | NOT PASS/NOT COMPLETED; process was stopped after extended no-output execution | Lint status remains unresolved |
| `npm run build` | FAIL in environment | `next/font` could not fetch Google Fonts; not a source security finding |
| Unsigned appointment POST | HTTP 401 | HMAC boundary verified |
| Signed nonce request | HTTP 200 | HMAC-protected nonce route verified |
| Appointment GET | HTTP 404 | POST-only route verified |
| Public custom REST list endpoints | HTTP 200 locally | Public content surface verified |
| Appointment route GET | HTTP 404 locally | No public listing/read route verified |
| Local GraphQL introspection probes | HTTP 404 | WPGraphQL unavailable in this local runtime; production state not verified |

## 7. Critical Findings

None demonstrated in the reviewed code.

## 8. High Findings

### SEC-001 — Public appointment proxy permits scalable abuse and shared-rate denial of service

**Severity:** High  
**OWASP/CWE:** OWASP API4/API6, CWE-400, CWE-799  
**Component:** Frontend / Integration / Backend  
**Files:** `frontend/src/app/api/appointments/route.ts`; `frontend/src/components/forms/AppointmentForm.tsx`; `backend/wp-content/plugins/brounhall-headless/includes/appointment-rest.php`  
**Affected endpoints:** `POST /api/appointments`; downstream `POST /wp-json/brounhall/v1/appointments`

**Evidence:**

- The Next.js route is anonymous and has no authentication, Origin validation, CAPTCHA/Turnstile, or server-side requester rate limiter.
- The honeypot, minimum elapsed time, client token, and duplicate fingerprint are all attacker-controlled or bypassable by a custom client.
- Each accepted proxy request first performs a WordPress nonce request and then a signed WordPress POST (`route.ts`, `getWordPressNonce`, and the downstream fetch).
- WordPress uses one global transient, `brounhall_appointment_rate_global`, with a limit of 30 POSTs per 15 minutes. It is not keyed by source, client, account, or appointment identity.
- A valid request creates a private WordPress appointment and can call `wp_mail` for configured recipients.

**Attack scenario:** A bot sends valid-shaped JSON directly to `/api/appointments`, varying email/message/client token values. It does not need the WordPress key because Next.js signs the downstream request. The bot can create records/send notifications until the global window is exhausted, causing HTTP 429 for legitimate visitors. If the notification transport is configured, this is also email and operational abuse.

**Impact:** Appointment spam, PII/health-information accumulation, notification abuse, and cross-user availability impact. The endpoint is intentionally public, so the HMAC protects WordPress from direct unauthenticated callers but does not protect the public proxy from automation.

**Existing mitigation:** Body limit, server validation, honeypot, timing check, HMAC, timestamp window, replay request ID, WP nonce, duplicate token/fingerprint, and a global rate limit.

**Remediation:** Add a production-grade edge/WAF bot control and per-client/IP rate limit before the nonce handshake. Use a durable rate-limit store where multiple Next instances are deployed. Keep a separate global circuit breaker, but do not use it as the only limiter. Add strict `Origin`/`Sec-Fetch-Site` policy for browser form requests, enforce `Content-Type`, set `Retry-After`, and add an abuse-monitoring/alerting path. Consider CAPTCHA/Turnstile for repeated failures or suspicious traffic. Define PII retention/deletion limits and do not send unnecessary health details by email.

**Verification:** Test with one valid request, repeated identical requests, varying client tokens, multiple source identities, missing/foreign Origin, malformed content type, and concurrent bursts. Confirm per-source limits do not block unrelated visitors; confirm only one private record is created for an idempotency key/fingerprint.

**Confidence:** High

## 9. Medium Findings

### SEC-002 — Protocol-relative CMS URLs are accepted by the shared link validator

**Severity:** Medium  
**OWASP/CWE:** OWASP A10, CWE-601  
**Component:** Frontend  
**File:** `frontend/src/lib/wordpress/page-content.ts:64-83`

**Evidence:** `safeHref()` returns any value beginning with `/` before rejecting `//`. Therefore `//attacker.example` is accepted as a URL. The treatment-specific adapter later rejects protocol-relative values, but the shared validator is used by multiple CMS page mappers.

**Attack scenario:** An editor or compromised CMS record supplies a protocol-relative CTA/link. The browser follows it as an external URL under the current scheme, enabling phishing/open-navigation behavior and bypassing the stated internal-path policy.

**Impact:** Unsafe CMS navigation and potential open-redirect-style user displacement. This is not a JavaScript execution finding by itself.

**Remediation:** Check `href.startsWith("//")` before accepting `/`; require exactly one leading slash for internal paths, reject backslash/control-character variants, and add tests for `//host`, `/\\host`, encoded schemes, and mixed-case schemes.

**Verification:** Unit-test `safeHref("//example.com") === ""` and verify every CMS link mapper uses the shared function.

**Confidence:** High

### SEC-003 — Environment and indexing policy is not environment-aware

**Severity:** Medium  
**OWASP/CWE:** CWE-16, OWASP A05  
**Component:** Frontend / Deployment  
**Files:** `frontend/src/app/layout.tsx:50-53`; `frontend/src/app/robots.ts`; `frontend/src/lib/site.ts`; `frontend/src/lib/wordpress.ts:33`

**Evidence:** Root metadata sets `robots.index: true` and `follow: true`; `robots.ts` allows all crawlers. The canonical/public site URL is hardcoded in `src/lib/site.ts`. `src/lib/wordpress.ts` falls back to a local WordPress GraphQL URL when `WORDPRESS_GRAPHQL_URL` is absent.

**Impact:** A staging/development deployment can be indexed and emit production canonicals, and a misconfigured production build can silently target a local CMS hostname. This can leak non-production content or create cross-environment content confusion.

**Remediation:** Make `PUBLIC_SITE_URL`, robots policy, and canonical policy environment-driven with fail-closed staging/development defaults (`noindex,nofollow`). Remove the local GraphQL fallback; missing configuration must fail clearly. Validate production URLs are HTTPS and belong to an approved deployment configuration.

**Verification:** Build dev, staging, and production-like environment matrices and inspect `robots.txt`, initial metadata, canonical URLs, and server-side WordPress destinations.

**Confidence:** High

### SEC-004 — No application-owned security headers are configured

**Severity:** Medium  
**OWASP/CWE:** OWASP A05, CWE-693  
**Component:** Frontend / Infrastructure  
**File:** `frontend/next.config.ts`

**Evidence:** `next.config.ts` configures redirects, images, and runtime options but no `headers()`/middleware policy for CSP, `frame-ancestors`/X-Frame-Options, HSTS, Referrer-Policy, Permissions-Policy, or X-Content-Type-Options. Hosting headers were not independently available for verification.

**Impact:** Clickjacking, MIME sniffing, referrer leakage, and weaker XSS defense-in-depth remain possible. A CSP must be designed against actual font/image/analytics dependencies, not copied as a wildcard policy.

**Remediation:** Add and verify production headers at Next.js or the trusted edge. Start with `X-Content-Type-Options: nosniff`, strict Referrer-Policy, Permissions-Policy, frame protection, and HSTS only on HTTPS production. Add a tested CSP with explicit sources and no unnecessary `unsafe-eval`/wildcards.

**Verification:** Inspect production/staging responses with `curl -I` and run CSP/report-only validation against all pages and form routes.

**Confidence:** High for repository absence; hosting status not verified.

### SEC-005 — Appointment records contain sensitive personal/health-adjacent data without a documented retention/privacy control

**Severity:** Medium  
**OWASP/CWE:** OWASP A02/A04, CWE-359  
**Component:** Backend / Operations  
**Files:** `backend/wp-content/plugins/brounhall-headless/includes/appointment-rest.php:40-48`; `appointment-fields.php`

**Evidence:** Name, email, phone, clinic, treatment, and free-text message are stored indefinitely as private post meta and included in notification email. No retention schedule, deletion workflow, access audit, encryption-at-rest requirement, or redaction policy was found in the project code/docs.

**Impact:** Long-lived exposure of fertility-related inquiry data to WordPress administrators, database backups, mailboxes, and logs/support systems. This requires a separate privacy/compliance review before production use.

**Remediation:** Minimize free-text collection, publish a retention period, implement controlled deletion/anonymization, restrict appointment capabilities to a dedicated least-privilege role, secure mail transport, avoid sending sensitive message content where unnecessary, and document UAE privacy/compliance ownership.

**Verification:** Review database/mail retention, admin role access, backups, support tooling, and deletion tests with the data owner.

**Confidence:** High

## 10. Low Findings

### SEC-006 — JSON-LD is inserted with `dangerouslySetInnerHTML` without script-safe serialization

**Severity:** Low (Medium if CMS/user-controlled values are later passed)  
**OWASP/CWE:** CWE-79  
**Component:** Frontend  
**File:** `frontend/src/components/seo/JsonLd.tsx:1-7`

**Evidence:** `JSON.stringify(data)` is inserted directly into a `<script type="application/ld+json">`. JSON strings containing `</script>` can terminate the HTML script element unless `<`, `>`, and `&` are escaped. Current call sites reviewed use code-owned data, so exploitability through the current public input was not demonstrated.

**Remediation:** Serialize with a script-safe JSON-LD helper that replaces `<`, `>`, `&`, U+2028, and U+2029, and add a regression test with `</script><script>`. Keep CMS rich text out of JSON-LD unless separately normalized.

**Confidence:** High for the unsafe sink; Low for current exploitability.

## 11. Informational / Hardening

- `frontend/src/lib/wordpress.ts` lacks the explicit `server-only` marker used by the REST modules, a request timeout, response-size bound, and centralized error normalization. It is currently imported by server pages, but the boundary is not mechanically enforced.
- The local `backend/wp-config.php` contains development database settings and WordPress salts. It is ignored and not shown as a tracked file, but deployment packaging must exclude it and production must use secret-managed values. Do not rotate/report the values in this document.
- `WP_DEBUG` is false in the local config. Production `display_errors`, file editing, XML-RPC, admin MFA, WAF, backups, and plugin/core patching were not verifiable from this repository.
- Custom public REST collections are bounded (50/100 records) and detail endpoints explicitly require `publish`; this is a positive control.
- Appointment HMAC uses a timestamp, constant-time comparison, and request-ID replay transient. It is stronger than a public WordPress mutation, but it does not solve public proxy abuse.
- Local GraphQL returned HTTP 404 for safe introspection probes. The application still contains a GraphQL reader; enable/secure the intended production contract or remove the unused path.

## 12. Frontend Assessment

Positive: REST data clients use `server-only`, configured-origin construction, timeouts, response-size checks in most modules, slug validation, and allow-listed treatment fields. Appointment secrets are accessed only by the Node route handler.

Risks: shared link validation accepts protocol-relative URLs; the global GraphQL client lacks equivalent hardening; JSON-LD uses a raw script sink; metadata/robots are not environment-aware; no security headers are defined; and the public appointment route lacks a robust edge abuse control.

## 13. WordPress Assessment

Positive: project CPTs are non-public and not exposed through default `wp/v2`; admin meta boxes use capability checks and nonces; structured fields are normalized and output is escaped; public custom REST responses only query published posts; appointment records are private.

Risks: the appointment endpoint’s global limiter is not requester-scoped; appointment PII retention is undefined; public endpoints use `__return_true` by design and depend on correct published-only filtering; WordPress production hardening/MFA/WAF/backup state is not verifiable; local `wp-config.php` must never enter a deployment artifact.

## 14. REST Assessment

| Endpoint | Method | Access | Result |
|---|---|---|---|
| `/wp-json/brounhall/v1/treatments` | GET | Anonymous | 200 locally; published bounded list |
| `/wp-json/brounhall/v1/treatments/{slug}` | GET | Anonymous | Code filters publish and validates slug |
| `/wp-json/brounhall/v1/doctors` | GET | Anonymous | 200 locally; published bounded list |
| `/wp-json/brounhall/v1/doctors/{slug}` | GET | Anonymous | Code filters publish and validates slug |
| `/wp-json/brounhall/v1/clinics` | GET | Anonymous | 200 locally; published bounded list |
| `/wp-json/brounhall/v1/clinics/{slug}` | GET | Anonymous | Code filters publish and validates slug |
| `/wp-json/brounhall/v1/appointments/nonce` | GET | HMAC | Signed request returned 200 locally |
| `/wp-json/brounhall/v1/appointments` | POST | HMAC + nonce | Unsigned request returned 401; no public GET route |

No public appointment list or raw appointment meta endpoint was found.

## 15. GraphQL Assessment

The frontend contains a fixed global-settings query, not arbitrary caller-controlled GraphQL. However, there is no repository evidence of persisted-query enforcement, complexity limits, introspection policy, or mutation disabling at the WordPress runtime. Local `/graphql` returned 404, so production GraphQL behavior is **NOT VERIFIABLE**. Production must explicitly verify anonymous read-only schema access, no mutation access, bounded query complexity, and no draft/private fields.

## 16. Preview Assessment

No preview route, preview cookie, draft loader, or authenticated preview implementation was found in the reviewed source. Preview appears not implemented. This avoids a demonstrated preview bypass but leaves the documented architecture incomplete; if added later it must be a separate authenticated, uncached trust boundary.

## 17. Revalidation Assessment

No revalidation/webhook route or signed invalidation implementation was found in the reviewed source. There is therefore no demonstrated webhook forgery/replay issue, but on-demand CMS invalidation is not implemented/verifiable.

## 18. Forms Assessment

The appointment form uses a server-only Next route, body limit, strict field allow-lists, honeypot, elapsed-time check, client token, WordPress nonce, HMAC, replay protection, duplicate fingerprint, and generic browser errors. The controls are materially better than a direct browser-to-WordPress mutation. The remaining release risk is the anonymous proxy abuse surface and lack of durable source-scoped bot/rate controls. The message may contain fertility/medical context; privacy review is required.

## 19. Supply Chain Assessment

`npm audit --json` reported zero vulnerabilities across the installed dependency graph at review time. This does not replace runtime patching or WordPress/plugin vulnerability monitoring. No Composer project was found for the project plugin; the WordPress core tree and third-party plugins require operational patch management.

## 20. CI/CD Assessment

No repository security workflow or deployment workflow was found in the inspected file set. Submodule discipline and production/staging environment pinning therefore require CI/operations verification. The parent/submodule worktrees were dirty during review; no release pointer update was made.

## 21. Production Configuration Assessment

Not verifiable from source: HTTPS enforcement, HSTS at the edge, WAF/bot management, WordPress admin restriction, MFA, XML-RPC policy, database encryption/backups, mail transport/DMARC, log retention/redaction, monitoring, alerting, and rollback.

## 22. Positive Security Controls Already Implemented

- Server-only marker on most REST data modules and the appointment route.
- WordPress base URL validation rejects credentials and unsafe schemes.
- Published-only custom REST queries and private appointment CPT.
- Slug and enum validation for doctors, clinics, treatments, and treatment links.
- Admin capability and nonce checks for project-owned structured fields/settings.
- Appointment HMAC, timestamp, request ID, WP nonce, duplicate token/fingerprint, payload limit, and generic public errors.
- No project-owned `eval`, shell execution, unserialize, dynamic include, or SQL query was found.
- No tracked `.env`, key, certificate, database dump, or log file was found by the repository file check.

## 23. Items Requiring Infrastructure Verification

HTTPS/TLS, HSTS, CSP/header delivery, WAF/Turnstile/bot controls, durable rate limiting, production GraphQL configuration, WP Engine private/admin controls, MFA, XML-RPC, debug/display errors, backups/restores, mail security, privacy retention, monitoring, alerting, and deployment artifact exclusion of local `wp-config.php`.

## 24. Release Blockers

1. SEC-001: public appointment proxy abuse and shared global rate denial of service.
2. SEC-003: staging/development indexing and hardcoded production canonical policy.
3. SEC-004: production security headers are not verified and are absent from application configuration.
4. SEC-005: personal/health-adjacent form data retention and notification handling lack an approved privacy control.
5. Production GraphQL security policy and WP Engine hardening are not independently verified.

## 25. Residual Risks

Even after code remediation, public forms remain abuse targets and need operational monitoring. WordPress core, plugins, admin accounts, hosting, mail, CDN, DNS, and backups are external security boundaries not proven by this repository.

## 26. Final Production Security Gate

**BLOCKED — high-risk production security defects remain** until SEC-001 is remediated and the listed production controls are verified.

