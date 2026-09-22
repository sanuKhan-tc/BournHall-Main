# Security Remediation Plan

## P0 — before production

### SEC-001: Protect the appointment proxy from abuse

- **Owner:** FE / BE / DEVOPS / SECURITY
- **Files:** `frontend/src/app/api/appointments/route.ts`; `backend/.../appointment-rest.php`
- **Fix:** Add edge/WAF bot control, strict Origin policy, durable per-source rate limits before the nonce handshake, and monitoring. Keep the global circuit breaker only as a secondary safeguard. Return `Retry-After`. Add CAPTCHA/Turnstile after suspicious attempts.
- **Test:** Concurrent/retry/rotating-token tests; prove unrelated users are not blocked by one source.
- **Dependency:** Production edge/rate-limit store and privacy approval.

### SEC-005: Approve PII retention and notification handling

- **Owner:** SECURITY / PRIVACY / BE
- **Files:** `backend/.../appointment-rest.php`, `appointment-fields.php`, documentation
- **Fix:** Define data minimization, retention/deletion, least-privilege appointment access, mail handling, backup retention, and incident process. Avoid including free-text health details in notification email unless approved.
- **Test:** Access/retention/deletion/mail review.

### SEC-003: Fail closed by environment

- **Owner:** FE / DEVOPS
- **Files:** `frontend/src/app/layout.tsx`, `src/app/robots.ts`, `src/lib/site.ts`, `src/lib/wordpress.ts`
- **Fix:** Remove local URL fallback, make canonical/robots configuration environment-specific, and default non-production to noindex/nofollow.
- **Test:** Dev/staging/production metadata and WordPress-origin matrix.

## P1 — before security sign-off

### SEC-002: Fix protocol-relative URL acceptance

- **Owner:** FE
- **File:** `frontend/src/lib/wordpress/page-content.ts`
- **Fix:** Reject `//` before accepting internal paths; add link safety tests.

### SEC-004: Add and verify security headers

- **Owner:** FE / DEVOPS
- **File:** `frontend/next.config.ts` or trusted edge configuration
- **Fix:** CSP based on actual dependencies, frame protection, nosniff, Referrer-Policy, Permissions-Policy, and production HSTS.
- **Test:** Header checks on staging and production-like deployments.

### SEC-006: Make JSON-LD script-safe

- **Owner:** FE
- **File:** `frontend/src/components/seo/JsonLd.tsx`
- **Fix:** Escape script-breaking characters before `dangerouslySetInnerHTML`; add a regression test.

### GraphQL control gap

- **Owner:** BE / DEVOPS
- **Fix:** Verify or implement approved persisted read operations, anonymous mutation denial, introspection policy, query depth/complexity limits, and published-only access. Add contract tests.

## P2 — shortly after launch

- Add explicit `server-only` and centralized timeout/size/error handling to `src/lib/wordpress.ts`.
- Add security CI: secret scan, PHP coding/security checks, dependency audit, lockfile review, and submodule SHA checks.
- Add REST contract tests for drafts/private/revisions and all invalid slug/type cases.
- Document WordPress admin MFA, file editor, XML-RPC, backup/restore, WAF, patch cadence, and incident ownership.

## Remediation validation addendum — 2026-09-22

- SEC-001 code controls are implemented, but production distributed enforcement remains **REQUIRES INFRASTRUCTURE**. Configure a durable shared limiter or verified edge/WAF equivalent before production; keep `APPOINTMENT_RATE_LIMIT_MODE` unset in production so the route fails closed rather than using process-local state.
- SEC-002 and SEC-006 are remediated and covered by `frontend/tests/security-regression.test.ts`.
- SEC-003 and SEC-004 are application-remediated but require deployment verification of explicit production environment values and delivered headers.
- SEC-005 technical minimization is implemented; retention/deletion/access policy is **REQUIRES PRIVACY/DATA OWNER APPROVAL**.
- GraphQL runtime, WordPress hardening, WAF, MFA, backups/restore, and edge security remain **NOT VERIFIABLE** from this local repository/runtime.
- `.github/workflows/security.yml` adds FE/BE checks and deployment-artifact guards. Pin third-party action SHAs as a supply-chain hardening follow-up.
