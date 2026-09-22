# Production Security Gate

## Decision

**BLOCKED — high-risk production security defects remain**

## Required closure conditions

- [ ] SEC-001 appointment abuse controls are implemented and load-tested with per-source limits, bot control, Origin policy, and monitoring.
- [ ] Appointment PII retention, access, deletion, backup, and notification handling are approved by the privacy/data owner.
- [ ] Non-production environments emit `noindex,nofollow` and do not use production canonicals.
- [ ] Protocol-relative CMS links are rejected by tests and code.
- [ ] Security headers are present and verified at the actual production edge.
- [ ] JSON-LD serialization is script-safe.
- [ ] WPGraphQL production exposure is independently tested for read-only/published-only behavior, mutation denial, introspection policy, and complexity limits.
- [ ] WordPress production hardening is verified: HTTPS, debug off, file editor disabled, MFA, least privilege, XML-RPC decision, WAF, patching, backups, restore test, and monitoring.
- [ ] Deployment artifacts exclude local `wp-config.php`, uploads, logs, and secrets.
- [ ] Frontend lint completes successfully and production build passes in a network-capable build environment.

## Evidence available

- PHP syntax checks passed for project plugin files.
- TypeScript check passed.
- `npm audit --json` reported zero vulnerabilities.
- Unsigned appointment request returned 401.
- Signed nonce request returned 200.
- Public appointment GET returned 404.

## Not sufficient for sign-off

Local success does not prove WP Engine configuration, CDN headers, WAF/rate limiting, GraphQL policy, mail security, admin MFA, backups, or privacy compliance.

## Remediation decision — 2026-09-22

**CONDITIONAL — code-level remediation is substantially complete, but required production controls remain unverified.**

- SEC-001: **PARTIALLY REMEDIATED / REQUIRES INFRASTRUCTURE**. The application fails closed in production unless durable or edge rate limiting is configured. Do not enable the process-local memory limiter for multi-instance production.
- SEC-002: **REMEDIATED** and regression-tested.
- SEC-003: **PARTIALLY REMEDIATED**; explicit production environment configuration is required.
- SEC-004: **PARTIALLY REMEDIATED**; verify headers at the actual edge.
- SEC-005: **PARTIALLY REMEDIATED**; privacy/data-owner approval remains required.
- SEC-006: **REMEDIATED** and regression-tested.

Do not issue production security sign-off until durable appointment limiting or equivalent WAF/edge control, bot mitigation, GraphQL runtime policy, WordPress hardening/MFA/WAF/backups, delivered headers, explicit production environment values, deployment artifact scanning, and privacy retention/deletion approval are verified. The local build also needs network access to fetch the existing Google Font dependency; the font implementation was not changed.
