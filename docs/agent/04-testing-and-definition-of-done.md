# Testing and Definition of Done

## Validation Principle

Use the lowest-cost deterministic test that proves the change, then add broader integration coverage where the boundary requires it.

Never claim a command, environment test or deployment check passed unless it was actually run.

## Parent Repository Checks

For cross-repo work verify:

```text
- `git submodule status` reflects intended SHAs
- affected child repos are committed
- parent points at those exact commits
- no local-path submodule URLs
- no unexpected dirty child worktrees
- relevant docs updated
```

A fresh clone should be able to initialize submodules with:

```bash
git submodule update --init --recursive
```

## Backend Verification Areas

As applicable:

- PHP syntax/tooling checks;
- WordPress project-plugin tests;
- content type/taxonomy registration;
- ACF/default/visibility behavior;
- capability/nonces/sanitization;
- GraphQL fields and relationships;
- public/draft/private authorization boundaries;
- persisted operation compatibility;
- revalidation payload/signature generation;
- navigation/mega-menu configuration safety;
- SEO field exposure/defaults.

## Frontend Verification Areas

As applicable:

- lint;
- typecheck;
- unit/component tests;
- GraphQL document validation;
- generated-type consistency;
- mapper/nullability tests;
- build;
- route integration tests;
- revalidation verification;
- preview isolation;
- SEO metadata/canonical/sitemap/robots;
- accessibility of navigation/mega menu;
- responsive regression;
- security checks for client-side secrets/unsafe URLs.

## Contract Tests

When GraphQL changes, test approved operations against the target integration environment.

Validate:

- operation still exists;
- expected fields/types match;
- required nullability assumptions hold;
- pagination is bounded;
- relations resolve;
- public access returns only published content;
- drafts/private data remain unauthorized anonymously;
- SEO/media/menu fragments resolve.

## Cache/Revalidation Tests

For a representative content change:

```text
1. render/fetch initial content
2. confirm cached repeat behavior where observable
3. modify CMS content
4. trigger valid signed event
5. confirm expected tag/path invalidated
6. confirm changed content appears
7. confirm unrelated content remains healthy
```

Test negative cases for signature, modified payload, expiration/replay and unsupported events.

## SEO Definition of Done

For affected route types verify:

- title;
- meta description;
- canonical;
- robots;
- Open Graph;
- Twitter metadata;
- JSON-LD where applicable;
- logical H1;
- correct HTTP status;
- sitemap membership/exclusion;
- environment index policy.

## Accessibility / Responsive Definition of Done

For navigation and page integration, validate representative desktop/tablet/mobile widths and keyboard interaction.

The existing plan uses representative widths:

```text
1920
1536
1440
1200
1024
768
640
390
```

Do not interpret these as a requirement to redesign layouts; they are regression checkpoints.

## Cross-Repo Definition of Done

A cross-repository implementation is complete when:

- backend contract is implemented and verified;
- frontend consumer is implemented and verified;
- compatibility is tested at the integration boundary;
- security requirements for the flow pass;
- SEO/accessibility/cache implications are tested where relevant;
- child commits are available;
- parent pins the tested child commits;
- documentation reflects any contract/process change;
- known unverified items are explicitly reported.
