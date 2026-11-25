# WP Engine Headless Environments and Pipelines Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare the Bourn Hall parent, backend, and frontend repositories for controlled WP Engine headless Dev, QA/review, Staging, and Production promotion.

**Architecture:** WordPress remains the editorial CMS and is deployed as a project-plugin submodule through WP Engine SSH Gateway. Next.js is deployed by WP Engine Headless Platform and reads WordPress server-side. GitHub Actions validates every relevant child repository and deploys only the backend plugin; parent pointers record tested child SHAs.

**Tech Stack:** WordPress, WPGraphQL/approved REST routes, Next.js 16.3.5, Node/npm, PHP 8.4, GitHub Actions, WP Engine SSH Gateway, WP Engine Headless Platform, PowerShell content migration wrappers.

**Spec:** `docs/superpowers/specs/2026-11-25-wpengine-headless-design.md`, plus `docs/deployment.md`, `docs/content/content-migration-runbook.md`, and the repository `AGENTS.md` files.

## Global Constraints

- Do not deploy WordPress core, `wp-config.php`, uploads, runtime caches, database files, secrets, or machine-specific paths through Git.
- Backend-compatible additions deploy before frontend consumers; removals happen only after consumers no longer depend on them.
- Normal browser traffic must not query WordPress directly for page content.
- The empty local XAMPP database is not a CMS source and must not overwrite a populated target.
- Remote content migrations are dry-run first and require an explicit execute step.
- Development, QA, and staging must not be indexable; production indexing is enabled only after launch approval.
- A parent pointer may move only to a committed, pushed, tested child SHA.
- QA must be modeled as a preview environment or separate site unless the WP Engine account explicitly provides another environment.

## Review Focus

- Empty or wrong CMS source: the workflow must refuse to treat the local empty database as source content; verify counts before/after copy.
- Environment mix-up: GitHub Environment variables and frontend CMS URLs must target the same named environment.
- Secret exposure: deployment logs, client bundles, and committed files must not contain SSH keys, API keys, or preview credentials.
- Fallback masking: representative pages must prove WordPress data is being rendered, while intentionally missing records still use the documented fallback.
- Promotion drift: backend and frontend child SHAs must be captured and parent must point to the exact tested pair.

---

### Task 1: Capture environment inputs and freeze the source decision

**Files:**
- Modify: `docs/deployment.md`
- Modify: `docs/content/content-migration-runbook.md`
- Test: deployment checklist and recorded environment matrix in the documentation

**Interfaces:**
- Consumes: WP Engine site/environment names, source CMS identity, frontend URLs, GitHub repositories, and QA topology supplied by the owner.
- Produces: a non-secret environment matrix and a documented go/no-go gate for CMS copying.

- [ ] Record exact Dev, Staging, and Production WP Engine environment names and URLs; record QA as either Headless preview or a separate site.
- [ ] Record the authoritative CMS source. Reject the empty local XAMPP database as a source.
- [ ] Document the per-environment values for `WPE_ENV`, `WORDPRESS_BASE_URL`, `WORDPRESS_GRAPHQL_URL`, `PUBLIC_SITE_URL`, `WORDPRESS_ENVIRONMENT`, `PUBLIC_SITE_INDEXING`, allowed origins, and form API secret placement without recording secret values.
- [ ] Add a preflight checklist requiring a target backup, plugin version check, source/target URL check, and content-count verification before a copy or migration.
- [ ] Verify the documentation does not promise database rollback for a content-only change.
- [ ] Commit documentation only after the owner supplies the environment matrix.

### Task 2: Make the backend deploy workflow environment-aware

**Files:**
- Create or modify: `backend/.github/workflows/deploy-wpengine.yml`
- Remove or retain: `backend/.github/workflows/deploy-dev.yml` only after the replacement is verified
- Test: PHP lint and GitHub Actions workflow validation

**Interfaces:**
- Consumes: backend branches `dev`, `qa` if used, and `staging`; GitHub Environments with the same names; each environment’s `WPE_SSHG_KEY_PRIVATE` secret and `WPE_ENV` variable.
- Produces: plugin-only deployment to `wp-content/plugins/brounhall-headless/` with cache clearing and no WordPress core/database/upload deployment.

- [ ] Choose one workflow with branch-to-GitHub-Environment mapping (`dev`, `qa` when applicable, `staging`) instead of duplicating deploy logic.
- [ ] Keep `permissions: contents: read`, concurrency cancellation, PHP 8.4 setup, PHP syntax checks, WP Engine SSH Gateway action, plugin-only `SRC_PATH`/`REMOTE_PATH`, and cache clearing.
- [ ] Add a manual dispatch path whose selected branch still resolves to the intended GitHub Environment; do not provide an arbitrary target input that can deploy production accidentally.
- [ ] Configure repository/environment protection rules and required approvals for staging/production; production deployment should be an explicit promotion, not an automatic push from `dev`.
- [ ] Run the same PHP lint locally and inspect the workflow YAML for unbound secrets/variables.
- [ ] Push the backend child commit before changing the parent pointer.

### Task 3: Add frontend CI and Headless Platform deployment contract

**Files:**
- Create: `frontend/.github/workflows/ci.yml`
- Modify: `frontend/README.md`
- Modify: `docs/deployment.md`
- Test: frontend lint, TypeScript, security test, and production build

**Interfaces:**
- Consumes: frontend pull requests and pushes to `dev`/`qa`/`staging`; WP Engine Headless Platform environment configuration.
- Produces: a CI gate for `npm ci`, lint, typecheck, security regression test, and build; platform settings for `npm ci`, `npm run build`, and `npm run start`.

- [ ] Add CI for pull requests and the agreed promotion branches using the repository’s existing Node/npm setup; do not add dependencies solely for CI.
- [ ] Run `npm ci`, `npm run lint`, `npx tsc --noEmit`, `npm run test:security`, and `npm run build`.
- [ ] Document that WP Engine Headless Platform connects directly to the frontend repository and deploys the selected branch; GitHub Actions validates but does not duplicate the platform runtime deployment.
- [ ] Document server-only variables and explicitly exclude `WORDPRESS_APPOINTMENT_API_KEY` and other secrets from `NEXT_PUBLIC_*` values.
- [ ] Configure separate Headless Platform environments/branches and their environment variables. Use `PUBLIC_SITE_INDEXING=false` outside production.
- [ ] Set each backend WordPress Headless Plugin frontend URL to the matching frontend environment URL.
- [ ] Preserve the current Webpack dev fallback for the Turbopack font-resolution issue; do not change production build tooling unless the platform reproduces that failure.
- [ ] Push the frontend child commit only after the full CI-equivalent checks pass.

### Task 4: Bootstrap Dev CMS content safely

**Files:**
- Modify: `docs/content/content-migration-runbook.md`
- Use: `tools/content-migrate.ps1`
- Use: `tools/seed-arabic-content.ps1`
- Use: `tools/seed-blogs.ps1`
- Test: WP Engine Dev REST/GraphQL smoke checks and representative frontend routes

**Interfaces:**
- Consumes: a populated WP Engine source environment or an explicitly approved content/migration source; deployed backend plugin; Dev frontend URL.
- Produces: a Dev WordPress environment whose content/media and plugin contracts can be consumed by the Dev Next.js app.

- [ ] Take and record a target Dev backup before any copy or write.
- [ ] If the source is a populated WP Engine environment, use the WP Engine copy flow with the correct source/target direction and URL replacement; do not copy from the empty local schema.
- [ ] If the source is not a WP Engine environment, stop and obtain approval for a complete database/media migration; do not improvise a SQL import or copy attachment IDs.
- [ ] Deploy the backend plugin first, then verify WordPress REST routes, WPGraphQL/approved operations, permalinks, published-only behavior, media URLs, and the plugin schema/version.
- [ ] Run the content manifest tool in dry-run mode, review warnings and unresolved source items, then execute only approved content changes.
- [ ] Verify counts for pages, services/treatments, doctors, clinics, FAQs, navigation, SEO records, and media references where applicable.
- [ ] Validate the Dev frontend renders CMS-backed content on representative English and Arabic routes and that missing records use the documented fallback without masking a transport error.
- [ ] Record the backend and frontend SHAs used for the successful smoke test.

### Task 5: Establish QA/review and Staging promotion

**Files:**
- Modify: `docs/deployment.md`
- Modify: `docs/content/content-migration-runbook.md`
- Test: promotion smoke suite and index-policy checks

**Interfaces:**
- Consumes: tested Dev backend/frontend SHAs and Dev CMS content.
- Produces: a repeatable review path and a staging environment that is content-compatible with the tested release.

- [ ] Decide whether QA is a Headless preview environment or a separate WP Engine site; document its URL and branch/preview trigger.
- [ ] Keep QA/staging non-indexable and verify `robots`, canonical, sitemap, and metadata do not point to production or WordPress.
- [ ] Promote backend plugin code through a protected branch/environment; promote frontend through the Headless Platform branch/environment.
- [ ] Copy or seed content only with a recorded source/target and backup; do not treat code promotion as content promotion.
- [ ] Run representative home, treatment, doctor, clinic, Arabic, form-validation, and navigation checks against both frontend and CMS origins.
- [ ] Confirm draft/private records are not returned to anonymous requests and that forms remain server-mediated.

### Task 6: Parent integration and release record

**Files:**
- Modify: `docs/deployment.md` or create a release record under `docs/releases/`
- Modify: parent submodule pointers for `frontend` and `backend`
- Test: parent status, submodule status, clean child worktrees, and integration smoke checks

**Interfaces:**
- Consumes: pushed, tested child commits and environment validation evidence.
- Produces: a parent commit identifying a compatible frontend/backend SHA pair and the deployment evidence needed to reproduce it.

- [ ] Confirm each child worktree is clean except intentional ignored runtime files.
- [ ] Confirm child commits are pushed and available to CI before updating parent pointers.
- [ ] Update the parent `frontend` and `backend` gitlinks to the tested SHAs.
- [ ] Run `git submodule status`, `git diff --check`, and verify no local-path submodule URLs or secrets were introduced.
- [ ] Record the tested environment, CMS source, frontend URL, backend URL, child SHAs, checks, and unresolved blockers.
- [ ] Commit the parent integration record only after child commits and environment checks are complete.

## Required commands

Frontend:

```bash
npm ci
npm run lint
npx tsc --noEmit
npm run test:security
npm run build
```

Backend/plugin:

```bash
find wp-content/plugins/brounhall-headless -type f -name '*.php' -print0 | xargs -0 -n1 php -l
```

Parent:

```bash
git submodule status
git diff --check
git submodule foreach --recursive "git status --short --branch"
```

## Completion criteria

The change is complete only when Dev CMS content is sourced from a confirmed
populated source, backend and frontend deployments are independently verified,
QA/Staging promotion is documented and protected, non-production indexing is
blocked, the representative content/form/security checks pass, child commits
are pushed, and the parent pins those exact tested SHAs.
