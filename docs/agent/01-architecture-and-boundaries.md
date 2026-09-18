# Architecture and Repository Boundaries

## Repository Topology

```text
Parent repository
├── frontend/   Next.js submodule
├── backend/    WordPress project submodule
├── docs/
└── .gitmodules
```

The parent repository is not a monolith containing mutable copies of both apps. It is the integration record that pins compatible child commits.

## Runtime Topology

### Local

```text
Browser
  |
  v
Next.js dev server
  |
  | server-side GraphQL
  v
XAMPP Apache -> WordPress -> WPGraphQL
```

### Hosted

```text
Visitor
  |
  v
Next.js / CDN
  |
  | approved server-side content reads
  v
WPGraphQL / WP Engine cache
  |
  v
WordPress
```

## Content Flow

```text
WordPress content
      |
      v
named GraphQL operation
      |
      v
frontend validation/mapping
      |
      v
frontend view model
      |
      v
existing UI component
```

The UI should not depend directly on raw ACF shapes.

## Contract Boundaries

### Backend -> Frontend API contract

Treat the following as contracts:

- GraphQL type/field names;
- named queries/fragments;
- nullable/non-null expectations;
- page-section discriminators;
- menu/mega-menu layout enum values;
- SEO fields;
- revalidation event schema;
- preview authentication flow;
- redirect records when enabled.

A contract change requires cross-repository review and validation.

### CMS -> Presentation boundary

CMS may control:

- content text/media;
- order;
- relationships;
- approved layout variant enum/configuration;
- links and SEO values.

CMS must not control:

- arbitrary React component names;
- arbitrary JavaScript/CSS;
- unrestricted executable markup;
- server secrets;
- cache purge paths;
- infrastructure configuration.

## Compatibility Strategy

Prefer additive migration:

```text
1. backend adds new field/contract while keeping old behavior
2. validate GraphQL
3. frontend starts consuming new field
4. deploy/verify frontend
5. remove old field only in a later compatible release
```

Avoid simultaneous destructive backend removal + frontend dependency change.

## Caching Layers

There are two independent cache concerns:

1. WP Engine/WPGraphQL public response caching;
2. Next.js page/data caching.

A CMS update may need invalidation in both layers. Do not assume clearing one automatically handles the other.

## Source Layout Guidance

The actual repository convention takes precedence, but preserve these conceptual boundaries:

### Frontend

```text
src/
├── app/api/revalidate/
├── app/api/preview/
├── components/cms/
└── lib/
    ├── wordpress/
    ├── seo/
    ├── navigation/
    └── security/
```

### Backend

```text
backend/
├── plugin/barun-hall-headless/
├── acf-json/
└── config/
```

Do not force a folder rewrite merely to match the example if the existing repository has equivalent clean boundaries.
