# Agent Execution Workflow

## 1. Start With Evidence

Before editing:

```text
- inspect git status in parent
- inspect git submodule status
- inspect git status in each affected submodule
- read nearest AGENTS.md
- read relevant implementation plan
- inspect existing code/tests/config
```

Do not assume the submodules are clean, initialized, on expected branches or at expected SHAs.

## 2. Classify the Change

Choose one:

### Parent-only

Examples:

- integration documentation;
- `.gitmodules` maintenance;
- orchestration scripts;
- release manifest;
- submodule pointer update after child changes are complete.

### Frontend-only

Examples:

- mapper bug;
- metadata rendering;
- safe URL normalization;
- cache tag behavior;
- Next.js component integration.

### Backend-only

Examples:

- CPT/field registration;
- ACF definition;
- CMS validation;
- GraphQL field exposure;
- WordPress publish hook.

### Cross-repo

Examples:

- new CMS section;
- GraphQL schema evolution;
- mega-menu contract change;
- SEO contract change;
- preview;
- revalidation;
- redirect model.

## 3. Plan Cross-Repo Changes Before Editing

Write the dependency order in implementation terms.

Example:

```text
Backend:
- add field/GraphQL support without breaking current query
- add/adjust tests

Frontend:
- update fragment/types
- update mapper
- update component
- update tests

Parent:
- pin tested BE SHA
- pin tested FE SHA
- update docs/release record if needed
```

## 4. Keep Changes Atomic

Prefer small changes that can be verified independently.

Do not bundle unrelated visual redesign, dependency upgrades or refactors into a CMS integration change unless required for correctness.

## 5. Submodule Commit Rules

A parent pointer update is meaningful only if the child commit exists and is available to other developers/CI.

Before updating parent pointer:

```text
- child worktree clean except intentional ignored files
- child tests/checks run
- child commit created
- child commit pushed to approved remote/branch or otherwise available per project workflow
```

Then update parent pointer and validate integration.

## 6. Avoid Destructive Git Operations

Do not use reset/clean/checkout operations that discard unknown user work.

Do not automatically switch branches or pull/rebase without understanding the existing state.

If the repo contains unrelated modifications, preserve them and scope the task around them.

## 7. Environment Handling

Never hardcode:

- local XAMPP path;
- WordPress URL;
- public site URL;
- credentials;
- webhook secret;
- preview credentials.

Use repository-defined environment templates and server-only variables.

## 8. Documentation Update Triggers

Update documentation when the task changes:

- bootstrap/submodule behavior;
- a public/internal contract;
- content/section models;
- environment variables;
- deployment sequencing;
- security controls;
- cache/revalidation behavior;
- release acceptance criteria.

## 9. Final Report Standard

For completed engineering work, report:

```text
Scope:
- parent / frontend / backend / cross-repo

Changed:
- exact important files/areas

Validated:
- exact commands/checks actually run

Compatibility:
- relevant FE/BE contract result

Not validated / blockers:
- anything not actually verified

Pointers:
- child commit(s) and parent pointer update, when available
```

Never report inferred success as executed validation.
