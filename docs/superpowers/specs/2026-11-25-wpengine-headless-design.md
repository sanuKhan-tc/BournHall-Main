# WP Engine Headless Environments Design

**Date:** 2026-11-25  
**Status:** Proposed; no hosting or CMS state has been changed.

## Intent

Make the existing Bourn Hall parent repository deployable as a headless
WordPress system on WP Engine, with separate development, QA/review, staging,
and production promotion paths. The goal is that editors can manage content
in WordPress and reviewers can see that content through the Next.js frontend.

## Current evidence

- `frontend/` and `backend/` are independently versioned submodules.
- The backend already has a plugin-only WP Engine SSH deploy workflow for `dev`.
- The frontend already reads WordPress server-side and has safe static fallbacks.
- The local XAMPP database is empty; it is not a valid source for a CMS copy.
- The repository has dry-run-first content migration scripts and reviewed seed
  manifests, but those do not reproduce an entire WordPress database or media
  library.
- The frontend currently uses REST for most page/entity reads, with GraphQL
  support for selected contracts. Deployment must not assume GraphQL is the
  only runtime dependency.

## Recommended approach

Use WP Engine Headless Platform for the Next.js application and GitHub Actions
with WP Engine SSH Gateway for the project WordPress plugin. Use a populated
WP Engine environment as the initial CMS source when possible, then copy
controlled environments through WP Engine. Use the repository migration
manifests only for approved content that is not present in the source.

QA is not assumed to be a fourth WP Engine environment. The default model is:

```text
backend dev       -> WP Engine Development CMS
frontend dev      -> Headless Platform development app
QA review         -> Headless preview environment or separate WP Engine site
staging           -> WP Engine Staging CMS + Headless Platform staging app
production        -> WP Engine Production CMS + Headless Platform production app
```

If the account has a separate QA site, it can be mapped to the same contracts;
the names and URLs must be configured rather than hardcoded.

## Content and database boundary

The empty local database must not be copied to WP Engine. If a populated WP
Engine environment already contains the intended CMS content, use an approved
WP Engine environment copy after taking a target backup and confirming the
source/target URLs. If the only source is an external SQL backup, stop for an
approved database-and-media migration design; the existing repository policy
does not treat arbitrary database replacement as the normal content migration
path.

After the backend plugin is deployed, content manifests may be applied through
`wp brounhall content migrate` or the existing PowerShell wrappers. Every
remote run is dry-run first, reviewed, then explicitly executed, followed by
content counts, representative route checks, and cache-window/revalidation
verification.

## Environment contract

Each environment receives its own values. Secrets stay in GitHub/WP Engine
environment settings and never enter Git.

Backend GitHub Environment variables:

- `WPE_ENV`: target WP Engine environment/install name.
- `WPE_SSHG_KEY_PRIVATE`: environment-specific SSH Gateway private key secret.

Frontend server-side variables:

- `WORDPRESS_BASE_URL`
- `WORDPRESS_GRAPHQL_URL`
- `WORDPRESS_ENVIRONMENT`
- `PUBLIC_SITE_URL`
- `PUBLIC_SITE_INDEXING`
- `WORDPRESS_APPOINTMENT_API_KEY`
- `APPOINTMENT_ALLOWED_ORIGINS`
- `COMPLAINT_ALLOWED_ORIGINS` when used by the deployed form route
- `FAUSTWP_SECRET_KEY` only where the connected platform/plugin requires it

Production uses HTTPS and indexing only after launch approval. Development,
QA, and staging remain non-indexable and use their own WordPress origin and
frontend origin.

## Non-goals

- Replacing the existing visual design.
- Deploying WordPress core, uploads, `wp-config.php`, or a database through Git.
- Adding browser-side WordPress requests.
- Introducing a fourth WP Engine environment without confirming the account
  topology.
- Treating static fallback content as the CMS source of truth.

## Alternatives considered

1. **Recommended: native Headless Platform + SSH plugin deploy.** Lowest
   infrastructure overhead and matches the repository’s current architecture.
2. **Seed-only migration.** Safer than an arbitrary database import and
   repeatable, but cannot reproduce the complete database/media state.
3. **Custom GitHub deployment for the frontend.** Possible, but duplicates
   the deployment responsibility already provided by WP Engine Headless
   Platform and adds avoidable runtime/hosting configuration.

## Approval gates

Before execution, confirm:

1. the populated CMS source environment or approved content source;
2. the WP Engine site/environment names for Dev, Staging, and Production;
3. whether QA is a Headless preview environment or a separate WP Engine site;
4. the frontend domains/preview URLs for each environment;
5. GitHub administrator access to the frontend, backend, and parent repos.
