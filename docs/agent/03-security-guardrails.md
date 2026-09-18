# Security Guardrails

## Trust Boundaries

```text
Public visitor
   |
   v
Next.js public application
   |                     \
   | content reads        \ form POST
   v                       v
WPGraphQL             server-side integration
   |
   v
WordPress

Privileged/editor flows are separate:
WordPress Editor -> authenticated preview / signed revalidation -> Next.js
```

## Public GraphQL

Public marketing content can be anonymous because it is public, but access must be constrained.

Required design:

- read-only public data;
- approved/persisted operations;
- bounded pagination;
- no arbitrary privileged fields;
- no public mutations;
- no public debug traces;
- controlled schema/introspection exposure according to environment policy;
- monitoring/caching of approved reads.

Do not add a privileged credential to every public content request merely to make the endpoint appear private.

## Secrets

Secrets remain server-side and outside source control.

Includes:

- Application Passwords;
- preview credentials;
- webhook/revalidation secrets;
- third-party private API keys;
- database credentials;
- private certificates.

Never place these in client-exposed environment variables or CMS fields.

## WordPress Hardening Expectations

Production should enforce, as applicable:

- HTTPS;
- MFA for privileged users;
- least-privilege roles;
- limited admin accounts;
- controlled plugin/core updates;
- unused plugin/theme removal;
- WordPress file editor disabled;
- XML-RPC disabled when not required;
- public debug output disabled;
- GraphQL debug disabled;
- backup/restore process;
- hosting WAF/security controls.

## Next.js Security

Validate CMS-derived URLs before rendering/redirecting.

Unsafe schemes should be rejected. External new-tab links require safe rel handling.

Security headers must reflect the actual integrations used by the site. Do not copy a permissive wildcard CSP as a shortcut.

## Revalidation Security

Required properties:

- POST only;
- HMAC/signature verification;
- timestamp validation;
- replay-window protection;
- constant-time comparison;
- strict event schema;
- event/content-type allow-list;
- rate controls for repeated failures;
- server-derived invalidation targets.

Never use an unauthenticated arbitrary `?path=` purge interface.

## Preview Security

- validate request before enabling preview;
- use least-privilege server-side authentication;
- uncached/no-store responses;
- draft/private content invisible to normal anonymous requests;
- prevent preview state or data from leaking into shared cache.

## Forms

Public form submissions go through a server boundary.

Minimum controls:

- POST;
- server-side schema validation;
- payload limits;
- rate limiting/bot protection where justified;
- origin/CSRF strategy appropriate to implementation;
- log redaction;
- generic failures;
- minimum-privilege downstream credentials.

If a form collects medical or other sensitive data, treat compliance/privacy review as separate launch work rather than assuming ordinary contact-form controls are sufficient.

## CMS Input Safety

Do not introduce editor-controlled execution of:

- arbitrary JavaScript;
- inline handlers;
- custom CSS;
- unrestricted iframe/embed code;
- raw executable markup;
- infrastructure secrets.

## Security Release Blockers

Block release if any of the following is present:

- anonymous draft/private content exposure;
- public mutation exposure contrary to policy;
- client-bundled secrets;
- unsigned/replayable revalidation;
- unsafe redirects/menu URLs;
- stack traces/secrets in public errors;
- critical unresolved dependency/security finding;
- staging indexable or production index policy wrong;
- canonical URLs pointing to WordPress/wrong environment.
