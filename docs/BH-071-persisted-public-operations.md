# BH-071 — Persisted Public Operations

## 1. Decision

**DONE — Level 1 application-side operation allowlist.**

The frontend now has one deterministic manifest generated from the canonical `.graphql` operation documents. Runtime calls must use an approved operation name and the exact composed document from that manifest.

## 2. Approved public operations

| Operation | Source | Runtime consumer |
| --- | --- | --- |
| `GetGlobalSettings` | `queries/global-settings.graphql` | Global settings data layer |
| `GetPrimaryNavigation` | `queries/primary-navigation.graphql` | Header/navigation data layer |
| `GetFooterNavigation` | `queries/footer-navigation.graphql` | Footer/navigation data layer |
| `GetPageByUri` | `queries/page-by-uri.graphql` | CMS page data layer |
| `GetDoctors` | `queries/doctors.graphql` | Doctor listing |
| `GetDoctorBySlug` | `queries/doctor-by-slug.graphql` | Doctor detail |
| `GetServices` | `queries/services.graphql` | Service listing |
| `GetServiceBySlug` | `queries/service-by-slug.graphql` | Service detail |
| `GetArticles` | `queries/articles.graphql` | Article listing |
| `GetArticleBySlug` | `queries/article-by-slug.graphql` | Article detail |
| `GetLocations` | `queries/locations.graphql` | Location listing |
| `GetLocationBySlug` | `queries/location-by-slug.graphql` | Location detail |
| `GetSitemapContent` | `queries/sitemap.graphql` | Sitemap content boundary |

Fragments are composed into each operation document and do not receive independent identities.

Department/Specialty and Redirect are absent by decision. No mutations or subscriptions are approved.

## 3. Manifest and hashing

`src/lib/wordpress/persisted-operations.json` contains the operation name, source path, composed canonical document, and SHA-256 digest. Generation normalizes line endings/trailing whitespace, resolves transitive fragments, sorts fragment definitions, rejects anonymous/non-query/duplicate operations, and verifies the exact approved inventory.

`persisted-operations:check` detects stale generated output; no random salts or timestamps are used.

## 4. Runtime boundary

`executeWordPressOperation()` rejects unknown names and documents that do not exactly match the manifest. Data modules now retrieve documents through `getApprovedWordPressOperation()`; React components do not contain GraphQL or direct WordPress fetches.

## 5. Backend capability and security level

WPGraphQL Smart Cache contains persisted-query and allow/deny infrastructure, including SHA-256 query IDs, but current deployment configuration was not verified as enforcing this project inventory. No backend code or configuration was changed.

Therefore this task achieves **Level 1: application-side operation allowlist only**. It is not Level 2 backend enforcement or Level 3 hash-only execution. WordPress may still accept arbitrary anonymous queries until BH-072 defines and verifies production policy.

## 6. Handoffs

BH-072 must decide and verify anonymous production access, including whether WordPress anonymous arbitrary queries, introspection, and mutations remain available.

BH-073 owns mutation hardening. BH-074 owns introspection/debug hardening. Neither was expanded here.

## 7. Validation

- persisted-operation inventory test passed;
- deterministic manifest check passed;
- `git diff --check` passed;
- TypeScript/build remain subject to the pre-existing BH-070 generated-schema errors in `src/lib/wordpress/generated/graphql.ts`.
