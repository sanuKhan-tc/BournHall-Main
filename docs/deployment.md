# Deployment

## Current scope: Dev only

This runbook currently covers the first WP Engine development environment.
QA, staging, and production workflows are intentionally not configured yet.

The backend repository's normal branch history was rewritten to remove tracked
WordPress core after the plugin-only split. Existing backend clones must
reclone or realign their branches before pushing. GitHub may retain objects
through immutable closed pull-request refs; removing those refs requires
GitHub Support or repository recreation and is separate from branch history.

The local XAMPP database is empty and must not be copied to WP Engine. Use a
populated WP Engine source environment for a controlled environment copy, or
use the reviewed content manifests after the backend plugin is deployed. Do
not perform an unreviewed SQL import or copy attachment IDs between sites.

## Backend repository deployment

The backend repository owns `.github/workflows/deploy-dev.yml`. Its `dev` branch
deploys only:

```text
wp-content/plugins/brounhall-headless/
```

WordPress core, `wp-config.php`, uploads, and the database are not deployed by
GitHub Actions.

Configure a GitHub Environment named `dev` in the backend repository with:

- Secret: `WPE_SSHG_KEY_PRIVATE`
- Variable: `WPE_DEV_ENV` — the WP Engine environment name

The workflow starts on a push or merge into the backend repository's `dev`
branch, or manually from the Actions tab.

## WP Engine Dev backend setup

1. In WP Engine User Portal, confirm the Dev environment exists and record its
   environment/install name and WordPress URL.
2. Enable the required WordPress plugins for the current backend contract,
   including WPGraphQL where the configured operations require it, and confirm
   permalinks are not set to Plain.
3. Open the Dev environment's SSH Gateway settings, generate an ED25519 deploy
   key, and add its public key to WP Engine.
4. Add the private key to the backend GitHub `dev` Environment as
   `WPE_SSHG_KEY_PRIVATE`.
5. Add the WP Engine environment/install name as `WPE_DEV_ENV`.
6. Push a plugin-only backend change to `dev` and verify the workflow and API.

The workflow does not deploy WordPress core, `wp-config.php`, uploads, or the
database. The current workflow is at
`backend/.github/workflows/deploy-dev.yml`.

Do not use the same key as a personal key. Do not commit the private key.

## Form submission storage

Appointment and patient complaint submissions are not stored in WordPress by
default. To explicitly enable encrypted record storage, add this to the target
environment's `wp-config.php`:

```php
define( 'BOURNHALL_STORE_FORM_SUBMISSIONS', true );
```

When the constant is absent or false, validated submissions are sent to the
configured notification recipients using the Bourn Hall HTML email templates
and are not encrypted or inserted as WordPress records. When storage is
enabled, the Appointment and Patient Complaint admin listing and record views
display a storage warning. When disabled, those views state that new
submissions are email-only and direct users to the system administrator.
Obtain privacy approval for retention, access, backups, and deletion before
enabling it.

## Dev CMS content setup

Choose one source before writing to Dev:

1. **Populated WP Engine source:** take a Dev backup, then in the WP Engine
   User Portal select the Dev environment as the destination and use
   `Actions -> Pull from` to copy from the populated source. Choose Full or
   Custom copy deliberately, confirm search/replace and source/target URLs,
   then verify content counts and media URLs. WP Engine's Pull action copies
   between WP Engine environments; it does not pull a GitHub repository.
2. **Reviewed repository content:** deploy the backend plugin first, run a dry
   run of the migration manifest, review warnings, then execute only approved
   records:

```powershell
$devSshHost = '<dev-user>@<dev-environment>.ssh.wpengine.net'
$devWpPath = '<dev-site-path>'

powershell -File tools/content-migrate.ps1 `
  -SeedFile tools/arabic-content.seed.json `
  -Target remote `
  -RemoteHost $devSshHost `
  -RemoteWpPath $devWpPath `
  -SshKey $env:USERPROFILE\.ssh\wpe_brounhall_deploy

powershell -File tools/seed-blogs.ps1 `
  -Target remote `
  -RemoteHost $devSshHost `
  -RemoteWpPath $devWpPath `
  -SshKey $env:USERPROFILE\.ssh\wpe_brounhall_deploy
```

Do not use the wrappers' legacy default host/path values for a new WP Engine
site; replace the placeholders with the values from the Dev environment.
Add `-Execute` only after the dry-run output and unresolved-content list have
been reviewed. These manifests are not a full database/media replacement.

## Why the backend currently uses GitHub Actions instead of WP Engine GitPush

The backend repository now tracks the project plugin, project tests/tools, and
CI guidance; the full local WordPress installation remains on disk and is
ignored. The supported workflow still intentionally deploys only
`wp-content/plugins/brounhall-headless/`. GitHub Actions uses SSH Gateway/rsync
with explicit source and destination paths, so it remains the safest
plugin-only deployment path.

WP Engine GitPush can be used with a repository that contains only the desired
site-relative files, but GitPush is still a push target rather than an
automatic GitHub pull service. A GitHub CI job would need to push the commit to
the WP Engine Git remote. It also has different branch behavior than the
current Actions workflow, so it is not part of the current Dev setup.

## Dev frontend setup

Connect the `frontend` GitHub repository directly to a WP Engine Headless
Platform application. Configure a Dev environment from the frontend `dev`
branch and set:

```text
Install: npm ci
Build:   npm run build
Start:   npm run start
```

Configure these as server-side Dev environment variables in the Headless
Platform. Use the matching Dev WordPress origin and frontend origin:

```text
WORDPRESS_BASE_URL=<dev WordPress origin>
WORDPRESS_GRAPHQL_URL=<dev WordPress origin>/graphql
WORDPRESS_ENVIRONMENT=development
WORDPRESS_CONTENT_REVALIDATE_SECONDS=60
PUBLIC_SITE_URL=<dev frontend origin>
PUBLIC_SITE_INDEXING=false
APPOINTMENT_ALLOWED_ORIGINS=<dev frontend origin>
COMPLAINT_ALLOWED_ORIGINS=<dev frontend origin>
WORDPRESS_APPOINTMENT_API_KEY=<server-side secret matching WordPress>
```

Keep API keys and preview/revalidation secrets out of `NEXT_PUBLIC_*` values.
Set the backend WordPress Headless Plugin's frontend URL to the same Dev
frontend origin. The frontend CI workflow runs on pull requests and pushes to
`dev`; WP Engine Headless Platform remains responsible for the Dev runtime
deployment.

## Dev verification

Run these checks after both child repositories are available:

```bash
cd frontend
npm ci
npm run lint
npx tsc --noEmit
npm run test:security
npm run build
```

Then verify the Dev origins directly:

```text
GET <dev WordPress origin>/wp-json/
GET <dev WordPress origin>/wp-json/wp/v2/pages?slug=home&_fields=id,slug,modified,content
GET <dev frontend origin>/
GET <dev frontend origin>/ar
```

Confirm the response contains the copied/managed CMS content, not only the
frontend's static fallback. Also confirm non-production `robots`/metadata do
not request indexing and that anonymous requests cannot read drafts/private
records.

The frontend is intentionally not deployed by the backend plugin workflow.
