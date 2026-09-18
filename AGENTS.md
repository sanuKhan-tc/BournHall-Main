# AGENTS.md — Parent Repository

## Purpose

This is the orchestration repository for the Barun Hall headless marketing website.

It coordinates two independently versioned Git submodules:

```text
parent-repository/
├── frontend/   # Next.js application submodule
├── backend/    # WordPress project code/configuration submodule
├── docs/
└── .gitmodules
```

The parent repository is the integration boundary. A parent commit must identify a tested, compatible frontend SHA and backend SHA.

## Read Before Making Changes

Before editing code, read in this order:

1. `docs/agent/00-source-of-truth.md`
2. `docs/agent/01-architecture-and-boundaries.md`
3. `docs/agent/02-execution-workflow.md`
4. `docs/agent/03-security-guardrails.md`
5. `docs/agent/04-testing-and-definition-of-done.md`
6. the nearest `AGENTS.md` inside the submodule being changed
7. the existing implementation plans under `docs/headless/`

Do not start implementation from memory when repository documentation exists.

## Core Architecture

```text
Editors
  |
  v
WordPress Admin
  |
  +-- Pages / structured content
  +-- SEO
  +-- Navigation / mega menu
  +-- Media
  |
  v
WPGraphQL
  |
  v
Next.js server-side data layer
  |
  +-- typed operations
  +-- validation / mappers
  +-- cache tags
  +-- metadata / JSON-LD
  |
  v
Existing Next.js components
  |
  v
Cached public website
```

### Ownership

**WordPress owns:** editorial content, publishing state, page-section ordering, reusable content relationships, navigation hierarchy, mega-menu configuration, SEO input fields, media metadata, and CMS-side revalidation events.

**Next.js owns:** rendering, routing behavior, component design, accessibility, server-side GraphQL consumption, CMS-to-view-model mapping, metadata output, JSON-LD, cache policy, form endpoints, validation, safe URL handling, and user-facing error behavior.

**Parent repo owns:** integration documentation, tested FE/BE submodule pointers, cross-repository compatibility, release records, and orchestration-level validation.

## Non-Negotiable Rules

1. Preserve the existing frontend design unless a task explicitly requests a visual change.
2. Do not modify WordPress core.
3. Do not commit XAMPP, WordPress core, uploads, runtime caches, database files, secrets, or developer-specific absolute paths.
4. Normal browser traffic must not query WordPress GraphQL directly for page content.
5. Do not introduce arbitrary GraphQL strings inside React components.
6. Public production content access is read-only and constrained to approved/persisted operations.
7. Do not expose public GraphQL mutations for site forms.
8. Preview is a separate authenticated, uncached trust boundary.
9. Revalidation must use a signed server-to-server POST flow with replay protection.
10. SEO must be rendered by Next.js into initial HTML and use the public frontend hostname.
11. Development and staging must not be indexable.
12. Keep schema changes backward-compatible across deployments whenever possible.
13. Backend-compatible additions deploy before frontend consumers; removals happen only after consumers no longer depend on them.
14. Never move a submodule pointer to an uncommitted, unpushed, or untested child state.
15. Never fabricate repository state, test results, environment state, GraphQL schema, WordPress configuration, or task completion.

## Repository Change Routing

Before editing, classify the task:

- **Parent-only:** docs, `.gitmodules`, orchestration scripts, release records, compatible submodule pointer updates.
- **Frontend-only:** Next.js rendering, data client, GraphQL documents consumed by FE, mappers, metadata, cache behavior, preview endpoint, form route handlers, FE tests.
- **Backend-only:** WordPress project plugin, ACF JSON/config, CPTs/taxonomies, GraphQL exposure, persisted-query setup, WordPress revalidation hooks, CMS validation, BE tests.
- **Cross-repo:** schema + query changes, preview, revalidation, mega menu, SEO model, new page-section contracts, deployment changes.

For cross-repo work, plan the compatibility sequence before editing either submodule.

## Submodule Discipline

A normal child-repository change follows:

```text
1. enter child submodule
2. create/use the correct feature branch
3. implement and test in child repo
4. commit child changes
5. push child commit
6. return to parent
7. update the submodule pointer
8. run parent/integration checks
9. commit parent pointer + related docs
```

Do not use `git submodule update --remote` as a default integration or release action. The parent must pin intentional SHAs.

If a child worktree is dirty before the task starts, do not overwrite or discard unknown changes. Inspect first and keep unrelated work intact.

## Required Planning Behavior

For any non-trivial change:

1. inspect the relevant source and current repository state;
2. identify affected repo(s), files, API/schema contracts, and risks;
3. state assumptions only when the source does not define them;
4. split implementation into small verifiable steps;
5. make the smallest compatible change;
6. run validation appropriate to each touched repo;
7. report exact files changed, validation performed, and remaining blockers.

Do not silently expand scope.

## Documentation Is Part of the Change

Update documentation when a change modifies any of the following:

- repository/bootstrap workflow
- GraphQL contract
- CMS content model
- navigation/mega-menu contract
- SEO fields/fallbacks
- cache tags or revalidation behavior
- preview/authentication behavior
- environment variables
- deployment order
- release/security requirements

The implementation plans in `docs/headless/` are design baselines. If implementation intentionally differs, record the decision rather than silently drifting.

## Security Stop Conditions

Stop and treat the work as blocked if implementation would require any of the following without an explicit approved design change:

- exposing a server secret to client code;
- browser-to-WordPress privileged requests;
- anonymous draft/private-content access;
- arbitrary public GraphQL mutations;
- unsigned or replayable cache revalidation;
- open redirect behavior;
- arbitrary editor-provided JavaScript/CSS/unsafe HTML execution;
- production/staging index policy that contradicts the documented environment rules;
- destructive production content/schema migration without rollback.

Do not work around these controls to make a test pass.

## Parent-Level Completion Checklist

A cross-repo task is complete only when:

- child changes are committed and pushed;
- the parent pins the intended child SHAs;
- relevant FE and BE checks pass;
- GraphQL compatibility is validated when the contract changed;
- no secrets or machine-specific paths were added;
- docs are updated when behavior/contracts changed;
- the final response identifies what was changed and what was actually validated.

See `docs/agent/04-testing-and-definition-of-done.md` for the full validation matrix.
