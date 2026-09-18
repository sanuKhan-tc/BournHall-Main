# Source of Truth and Documentation Map

## Purpose

This document tells coding agents which source to trust when instructions overlap.

## Priority

For implementation decisions, use the following precedence:

1. explicit current user/task instruction;
2. nearest repository `AGENTS.md`;
3. parent `AGENTS.md`;
4. current implementation plans under `docs/headless/`;
5. existing repository code and tests;
6. assumptions/inference only when the repository does not define the answer.

When code and documentation disagree, inspect history/current behavior and call out the mismatch. Do not silently choose one and rewrite the other.

## Baseline Source Documents

The parent agent context was derived from these project plans:

```text
docs/headless/
├── README.md
├── 00-local-development-submodule-setup.md
├── 01-frontend-backend-development-plan.md
├── 02-integration-plan.md
├── 03-testing-security-plan.md
├── 04-deployment-plan.md
└── 05-task-breakdown.md
```

The architecture baseline is also captured in the broader headless WordPress + Next.js integration plan.

## Stable Decisions Already Made

The following should not be re-litigated during routine implementation unless the task explicitly changes architecture:

- frontend is an existing Next.js application;
- backend is WordPress hosted on WP Engine Headless in deployed environments;
- local WordPress development uses XAMPP;
- frontend and backend are Git submodules of a parent integration repository;
- WordPress is the content/editorial authority;
- Next.js is the public rendering/application authority;
- normal visitor traffic does not perform direct WordPress GraphQL page-content reads from the browser;
- public GraphQL content access is read-only and controlled;
- general marketing pages use WordPress Pages;
- reusable domain data can use structured content types;
- SEO, navigation and mega-menu content are CMS-managed but rendered/validated by Next.js;
- page updates use targeted cache invalidation rather than full rebuilds by default;
- preview is authenticated and uncached;
- forms are server-mediated;
- production security and SEO configuration are release gates.

## Unknowns Must Stay Unknown Until Verified

Do not invent:

- actual repository URLs;
- exact branches;
- current package/plugin versions;
- current submodule SHAs;
- local XAMPP path;
- production domains;
- installed plugin state;
- current GraphQL schema;
- available test scripts;
- downstream form integrations.

Inspect the repository/environment before using any of those as facts.
