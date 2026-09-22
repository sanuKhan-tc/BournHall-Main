# Security Control Matrix

Status reflects repository evidence and safe local checks, not a production certification.

| Security Control | FE | BE | Deployment | Status | Evidence |
|---|---|---|---|---|---|
| Input validation | Partial | Pass | Not verified | PARTIAL | Appointment schema/allow-lists exist; no centralized schema library; public abuse remains |
| Output encoding | Partial | Pass | Not verified | PARTIAL | React escapes normal text; JSON-LD sink needs safe serialization |
| XSS protection | Partial | Pass | Not verified | PARTIAL | No raw CMS HTML renderer found; JSON-LD `dangerouslySetInnerHTML` is unsafe for future CMS data |
| SQL injection protection | Pass | Pass | Not verified | PASS | No project-owned `$wpdb` query or dynamic SQL found |
| Authentication | Partial | Pass | Not verified | PARTIAL | Public content is intentionally anonymous; appointment downstream uses HMAC, proxy is public |
| Authorization | Pass | Pass | Not verified | PASS | Admin capabilities; private CPT; publish filters |
| CSRF protection | Partial | Pass | Not verified | PARTIAL | WP nonce/HMAC downstream; no Origin strategy on public Next form |
| SSRF protection | Partial | Not verified | Not verified | PARTIAL | Base URL validates scheme/credentials but not approved host; env-controlled rather than user-controlled |
| Secret handling | Pass | Pass | PARTIAL | PARTIAL | Server-only appointment key; local `wp-config.php` must be excluded; environment wiring not CI-verified |
| REST security | Pass | Pass | Not verified | PARTIAL | Published bounded reads; appointment HMAC; rate limiter is global |
| GraphQL security | Partial | Not verified | Not verified | NOT VERIFIABLE | Fixed frontend query; WPGraphQL runtime/persisted policy unavailable locally |
| Preview isolation | N/A | N/A | N/A | NOT APPLICABLE | No preview implementation found |
| Revalidation authentication | N/A | N/A | N/A | NOT APPLICABLE | No revalidation endpoint found |
| Replay protection | Pass | Pass | Not verified | PASS | Request ID transient plus timestamp; appointment token/fingerprint |
| Form security | Partial | Pass | Not verified | PARTIAL | Strong validation and HMAC; no durable bot/edge control or retention policy |
| Rate limiting | Fail | Partial | Not verified | FAIL | WordPress global 30/15m limiter can be exhausted for all users; no FE limiter |
| Security headers | Not configured | N/A | Not verified | FAIL | No Next headers/middleware policy found |
| CORS | Not configured | Not verified | Not verified | NOT VERIFIABLE | No explicit CORS policy found; hosting behavior unknown |
| Cache isolation | Partial | Partial | Not verified | PARTIAL | Public reads cached; preview absent; appointment uses no-store; production cache behavior unverified |
| File/media security | N/A | Not verified | Not verified | NOT VERIFIABLE | WordPress core media/hosting not audited dynamically |
| Dependency security | Pass | Partial | Not verified | PARTIAL | `npm audit` zero; WordPress core/plugins patch state unknown |
| Supply chain | Partial | Partial | Not verified | PARTIAL | No security CI workflow found; submodules/worktrees dirty |
| CI/CD security | Not verified | Not verified | Not verified | NOT VERIFIABLE | No inspected deployment/security workflow evidence |
| Logging/redaction | Partial | Partial | Not verified | PARTIAL | Public errors generic; request/PII logging and retention not documented |
| Error handling | Pass | Pass | Not verified | PASS | Generic appointment errors; REST errors do not expose stack traces in reviewed code |
| Backup/rollback | N/A | N/A | Not verified | NOT VERIFIABLE | Operational control |
| Monitoring/alerting | N/A | N/A | Not verified | NOT VERIFIABLE | Operational control |

